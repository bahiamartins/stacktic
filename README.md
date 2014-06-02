# Stacktic is the Static Site Generator that follows MVC pattern

## The build process

1. Load configuration
2. Load collections
3. Pass collections to controllers to create pages
4. Write pages their dests

## Basic example:

At the bare minimum a StackTic website producing some output will consists of a single controller:

``` js
stacktic: {
  example_1: {
    dest: '_output',
    controllers: [
      'main.js'
    ]  
  }
}
```

Lets define our `main.js`:

``` js
module.exports = function(stacktic) {

  stacktic.route("/", 'home', function(render){
    render("Hi!");
  });

};
```

This stupid example will create an `[OUTDIR]/index.html` containing 'Hi!'.

__NOTE!__ when you specify a route ending with "/" an `index.html` will be automatically appended to the route path. So for instance: 

```
  stacktic.route('/sitemap.xml', function(){ /* ... */ });
```

Will output to `[OUTDIR]/sitemap.xml`. While:

```
  stacktic.route('/a.confusing.path/', function(){ /* ... */ });
```

Will output to `[OUTDIR]/a.confusing.path/index.html`.

### Using Models and DataStores

Models are javascript objects grouped in collections and pages are models as well.

Now lets do something better. Lets create a three page personal website with: home, about, and contacs. 

To do so we need to use models and data sources. Any model in StackTic is accessed through a data source. A data source is an object that is responsible to query and return data.

For now we will use a file based data source that parses YMF metadata.

``` js
stacktic: {
  example_2: {
    plugins: [ 'stacktic-yfm-ds' ]
    dest: '_output',
    controllers: [
      'main.js'
    ],
    datasources: {
      yfm: { 
        base: "pages" 
      }
    }
  }
}
```

``` js
module.exports = function(stacktic) {

  var ds = stacktic.ds.yfm;

  stacktic.route("/", 'home', function(render){
    ds.first('home.md', function(err, obj){
      render(obj._content);
    });
  });

  stacktic.route("/about", 'about', function(render){
    ds.first('about.md', function(err, obj){
      render(obj._content);
    });
  });

  stacktic.route("/contacts", 'contacts', function(render){
    ds.first('contacts.md', function(err, obj){
      render(obj._content);
    });
  });

};
```

Well this just the basics of a datasource, but this is not that intresting.. so lets plug in handlebars to see how views works. 

``` js
stacktic: {
  example_3: {
    plugins: {
      'stacktic-yfm-ds' : {
        base: "pages" 
      },
      'stacktic-handlebars': {
        // ..
      }
    },
    
    dest: '_output',
    controllers: [ 'main.js' ]
  }
}
```

``` js
module.exports = function(stacktic) {

  var ds = stacktic.ds.yfm;

  stacktic.route("/", 'home', function(render){
    ds.first('home.md', function(err, obj){
      render.hbs(obj);
    });
  });

}
```

That's all. Template engines should inject a function in renderer to transform an object in string.

Now lets see how we can create a blog instead.


``` js
module.exports = function(stacktic) {

  var ds = stacktic.ds.yfm;

  stacktic.route("/", 'home', function(render){
    ds.first('home.md', function(err, obj){
      render.hbs(obj);
    });
  });
  
  var i = 0;
  ds.get('posts/*', function(err, obj){
    stacktic.route("/blog/post-" + i, 'post', function(render){
      render.hbs(obj);
    });
  });

}
```





