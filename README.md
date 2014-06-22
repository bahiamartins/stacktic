# Stacktic

## A Stacked Static Site Generator for Node.js

Stacktic is the Static Site Generator that mimics MVC pattern. Working with MVC frameworks we learned clean architectures and patterns that correcty isolates responsabilities to create dynamic, data-driven websites. Why can't we have that for static sites too?

## Getting Started

### Install

*Stacktic* is released as npm package, so to install open a shell and type

``` sh
npm i -g stacktic
``` 

Then you will need to install stacktic as a local dependence, so run

``` sh
npm i stacktic --save-dev
```

from the site project folder.

### Usage

Although you can easily use stacktic by requiring it in your node.js scripts and gulp/grunt tasks it has a minimal command line interface that requires you to place a stackticfile.js or stackticfile.coffe in your project directory.

To build your just run

```
stacktic
```

from the site project folder.

### Reference directory structure

We will assume this directory structure across the following sections.

```
myWebsite/
  src/
    assets/
      js/
      css/
    controllers/
    models/
    layouts/
    pages/
  out/
  
  stakticfile.js
```

**NOTE:** You are not forced in any way to follow this configuration.

## Your first website

### Plugins

Stacktic plugins are very similar to grunt plugins: they are just functions.

``` js
module.exports = function(stacktic){
  // your code here
};
```

You can use a plugin requiring it with `#use` method.

``` js
stacktic.use('myplugin');
```

Obviously you can require plugins from a plugin itself

``` js
// myplugin.js
module.exports = function(stacktic){
  stacktic.use('anotherplugin');
};
```

### Stackticfile

stackticfile.js is a plain node script that is runned by stacktic CLI

``` js
var stacktic = require('stacktic');

stacktic({src: 'src', dest: 'dest'})
.model(/*... */)
.controller(/*... */)
.build();
```

### Organizing your sources

Althoug you can put everything in the `stackticfile.js` it is a good idea to split everithing in separate modules, especially to perform efficient rebuilds with gulp/grunt watch tasks.

So we will create a simple stackticfile that only requires models and controllers we will define elsewhere as plugins.

``` js
var stacktic = require('stacktic');

stacktic({src: 'src', dest: 'dest'})
.use('./src/models/page')
.use('./src/models/post')
.use('./src/models/comment')
.use('./src/models/vendor')
.use('./src/models/asset')
.use('./src/controllers/pages')
.use('./src/controllers/blogging')
.use('./src/controllers/assets');
```

### Models

Stacktic has models. A model collects and adapts data from different sources. Use the `#model` method to define a model. At the bare minimum a model should declare a data source.

``` javascript
module.exports = function(stacktic){
  
  stacktic
  .model("Page", function() {
    this.dataSource('fs', {
      src: 'pages/**/*'
    });
  })

};
```

You can postprocess and adapt data after their are loaded in many ways:

``` javascript
module.exports = function(stacktic){

  stacktic
  .model("Page", function() {
    this.dataSource('fs', {
      src: 'pages/**/*'
    });

    // Via plugins
    this.parseYfm();
    this.slug('title');
    this.parseDates('createdAt', 'updatedAt');

    // Via callbacks
    this.callback('validate:after', function(item){
      item.excerpt = item.$content.slice(0, 200) + "...";
    });
  });

};
```

Stacktic is not limited to the concept of using files as data, you can load them virtually from any source: APIs, databases, whatever ..., you will just need the right loader for that.

``` js
module.exports = function(stacktic){

  stacktic
  .model("Comment", function() {

    this.dataSource('rest', {
      url: 'http:/api.example.com/comments',
      format: 'json'
    });

    // Validate data from untrusted sources
    this.validate({'author': {presence: true}});
    
    // Adapt data as you wish with callbacks
    this.callback('load:after', function(item){
      item.reliability = item.totalVoters == 0 ? 1 : item.upVoters / item.totalVoters;
    })

    // Create instance methods
    this.prototype.isReliable(function(){
      return this.reliability > 0.5;
    });

    this.parseDates('postedAt');

  });

};

```

### Loaders

A loader is an internal component (although you can define yours) in charge to load data from data sources, making them javascript objects.

The main function of a loader is to create a special `$content` property, containing the content of the object. This will be used (but not strictly required) later to initiate the rendering process. 

#### $ stands for special

Across the build process an item will be augmented with special properties by components. These properties are useful to the end user in rendering process (eg. `$path` to link items) or for other components (eg. `$file` to specify item destination).

Any special property should be prefixed by `$` character. This is a convenience to avoid name clashes an to leave plain names free to use.

### Collections

Once a model is loaded it will expose a collection interface to query and manipulate model instances. Collections are a powerful way to handle data. Collection API is similar to many model querying DSLs.

Models will be available in controllers. So inside a controller you could do:

``` js
this.models.Page.where({$slug: home});
```

or

``` js
this.models.Post.sortBy('created_at', 'desc').paginate(10);
```

#### Collection API methods

This is the full list of collection methods. Most of them are adapters to [Lodash](http://lodash.com) collection methods, so refer to [Lodash Docs](http://lodash.com/docs) for a better explanation of their behaviour.

For other methods you will find documentation on Stacktic website.

##### Lodash Collections Methods

- at
- contain
- countBy
- every
- filter
- find
- findLast
- forEach
- forEachRight
- groupBy
- indexBy
- invoke
- map
- max
- min
- pluck
- reduce
- reduceRight
- reject
- sample
- shuffle
- some
- sortBy
- where

##### Native collection methods

- paginate
- slice
- offset
- limit
- first
- last
- concat
- append
- prepend
- push
- unshift
- pop
- shift
- sort
- merge
- toArray

Aliases

- include → contains
- all → every
- select → filter
- detect → find
- findWhere → find
- each → forEach
- eachRight → forEachRight
- collect → map
- foldl → reduce 
- inject → reduce
- foldr → reduceRight
- any → some

### Controllers

Inside controllers you will create routes, describe the rendering process of a route, bind model items to routes and build the rendering context.

**NOTE:** the `$slug` property is created via `#slug` method called in model that is provided by the built-in slug plugin.

``` javascript
module.exports = function(stacktic){

  stacktic
  .controller("Pages", function() {

    // Manipulate global rendering context
    this.context.nav = this.models.Page.where({nav: true}).sortBy('title');

    // Bind object to routes
    this.route("/", 
      this.models.Page.where({ 
        $slug: "home"
      })
    )

    // Mix whatever you want to local rendering context
    .context({ 
      isHome: true
    });

    // Create paths interpolating bound items properies
    this.route("/:{$slug}/", this.models.Page.reject({$slug: "home"}));

  });

};
```

**NOTE:** the name of a controller is only for further referencing purpose, you can call the way you prefer.  

Keep going to illustrate some more features:

``` javascript
module.exports = function(stacktic){

  stacktic
  .controller("Blogging", function() {

    // paginate will group items in pages that are 
    // abjects like this: {page: [page number], items: [items]}
    var blogPages = this.models.Post.sortBy('created_at', 'desc').paginate(10);

    // Some ways to manipulate items
    blogPages.limit(1).merge({
      title: "Blog"
    });
  
    var i = 1;
    blogPages.offset(1).forEach(function(item){
      i++;
      item.title = "Blog page " + i;
    });

    this.context.blogPages = blogPages;
    
    // Configure rendering
    this.route('/blog/', blogPages.limit(1))
    .render('hbs', {template: 'blog'})
    
    this.route('/blog/:{page}/', blogPages.offset(1))
    .render('hbs', {template: 'blog'});

    // Compose renderers
    this.route('/blog/posts/:{$slug}/', model.Posts.sortBy('created_at'))
    .context(function(item){
      this.comments = stacktic.models.Comment.where({postPath: item.$path});
    })
    .render('md').render('hbs');

  });

};
```

You can even setup unbound routes

``` js
module.exports = function(stacktic){

  stacktic
  .controller("Sitemap", function() {

    this.route('/sitemap.xml')
    .context(function(){
      this.sitemapItems = stacktic.createCollection()
      .append(this.models.Page.items)
      .append(this.models.Post.items)
    })
    .render('hbs', {
      template: 'sitemap', layout: false
    });

  });

};
```

### Routing and Rendering Context

Once a controller creates a route the route will setup a rendering context.
A rendering context is also called a renderable object (an object that is ready to be rendered).

A renderable will contain:

- Global context properties
- Local context properties (overriding globals)
- `$current` property referencing the bound object if route is bound
- `$path` as the current path
- `$file` the destination path calculated from $path appending index.html if the route path ends with '/'

If the route is bound it will copy the `$path` property in `$current` object to make inverse routing possible.

#### Path to `$file` mapping

- `route("/mypage/")` → '/mypage/index.html'
- `route("/mypage")` → '/mypage.html'
- `route("/mypage.extname")` → '/mypage.extname'
- `route("/mypage.extname/")` → '/mypage.extname/index.html'

### Rendering

Renderers transforms a string to another string optionally taking account of the current context. Stacktic currently ships with some built-in renderers:

- _hbs_: render handlebars templates, it has partials, layouts and some handy helpers pre-registered for you
- _md_: render markdown through marked and highlight.js 
- _less_: less
- _uglify_: minify javascript through `uglify`
- _cssmin_: minify css through `uglify`
- _toc_: creates toc using a dom parser

`hbs` is the default renderer, obviously you can change this.

You can learn more about rendering engines an other built in plugins on website.

### Views

Views are inputs for renderers. Views can be either taken from `$content` property of items
or passed as external templates if the rendering engine allows it.

#### A note about `hbs` renderer

`hbs` renderer ships with the ability to define layouts, partials and templates both from item content or from external templates.

It also has some convenient helpers both for common tasks like formatting dates and embedding markdown and for stacktic related tasks.

List of available helpers:

- md: renders section as markdown
- moment: format date with moment.js
- capture: capture a block from a template to be used in layout
- yield: used in layout will yield to template body if no argument is supplied or to a captured block if the block name is supplied 
- ifCurrent/unlessCurrent: run blocks conditionally according to the result of comparing the passed item with the current one

#### Examples

The following are some views according to the examples above.

```
<!-- layouts/default.hbs -->
<html>
<head>
  <meta charset="UTF-8">
  \{{#unless isHome}} \{{!-- we defined this in controller --}}
  <title>{{$current.title}} | My Website</title>
  \{{else}}
  <title>My Website</title>
  \{{/unless}}
</head>
<body>
  \{{{yield}}}
</body>
</html>
```

A partial
```
<!-- partials/nav.hbs -->
<ul class="nav navbar-nav navbar-right">
  \{{#each nav.items }}
    \{{#ifCurrent $path }}
      <li class="active"><a href="\{{$path}}">\{{title}}</a></li>
    \{{else}}
      <li><a href="\{{$path}}">\{{title}}</a></li>
    \{{/ifCurrent}}
  \{{/each}}
</ul>      

```

A page
``` 
<!-- pages/home.hbs -->
---
nav: true
---

<h1>Hi!</h1>
```

A template
``` 
<!-- templates/blog.hbs -->
<h1>\{{$current.title}}</h1>

\{{#each $current.items }}
<div class="post">
  <h2>\{{title}}</h2>
  <p>\{{excerpt}} <a href="\{{$path}}">Continue reading...</a></p>

</div>
\{{/each}}
```

A post
```
<!-- posts/my-first-post.md -->
---
title: My first post
created_at: 1-1-2014
---

Lorem ipsum dolor sit amet, consectetur adipisicing elit. Sunt, inventore, voluptatibus, cum fuga laboriosam reprehenderit quia veritatis quidem amet repellat dignissimos atque porro at temporibus minus ad rerum id officiis.
```