var stk = require('..');

stk.configure({
  plugins: {
    yfm : {
      base: "test/_fake" 
    },
    fs: {
      dest: 'test/_output'
    },
    hbs: {
      layoutsDir: 'test/_fake/layouts',
      partialsDir: 'test/_fake/partials'
    }
  },
  collections: {
    pages: 'yfm:/pages/*',
    posts: 'yfm:/posts/*'
  },
  logger: {
    verbose: false
  }
})

.controller(function(stk){
    var data = stk.context.collections,
        blogPages = data.posts.sortBy('created_at').paginate(10);

    stk.context.set('blog.pages', blogPages);
  
    stk.route('/', data.pages.where({slug: 'home'}));
    stk.route('/<%= slug %>/', data.pages.reject({slug: 'home'}));

    stk.route('/blog/', blogPages.limit(1));
    stk.route('/blog/<% page %>', blogPages.offset(1));
    stk.route('/blog/posts/<% slug %>', 'collections.posts');
    // stk.route('/sitemap.xml', sitemap);

});

stk.build();

it('should not raise on building', function(){
  var block = function(){
   
  };
  
  block.should.not.throw();
});
