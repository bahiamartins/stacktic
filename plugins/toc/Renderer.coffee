cheerio = require "cheerio"
slug = require "slug"
_ = require "lodash"

class Renderer
  @configure: (config = {}) ->
    @config = config

  constructor: (options = {}) ->
    @options =
      target: '.toc'
      container: 'body'
      levels: ['h2', 'h3', 'h4']
      listElem:  'ul'
      itemElem:  'li'
      listClass: 'nav'
      itemClass: 'toc<%= level %>'
      anchorFn: (elem) ->
        id = elem.attr("id")
        if not id?
          id = slug(elem.text()).toLowerCase()
          elem.attr("id", id)

        "##{id}"

    _.assign(@options, Renderer.config, options)

  render: (content, context, done) ->
    options = @options
    $ = cheerio.load(content)
    target = $(options.target)
    container = $(options.container)

    unless target.length and container.length and options.levels.length
      return done(null, content)

    selector = options.levels.join(',')
    headers = $(container).find(selector)

    tree = {parent: null, children: [], level: 0}

    findParent = (node, lvl) ->
      if node.level < lvl
        node
      else
        if node.parent is null
          throw new Error('Something went wrong it should not get here. This is a bug.')
        
        findParent(node.parent, lvl)

    # build tree
    headers.each () ->
      e = $(this)
      for i in [0...options.levels.length]
        selector =  options.levels[i]
        lvl = i + 1
        last = tree.children[tree.children.length - 1]
        if e.is(selector)
          if lvl == 1 or not last?
            tree.children.push {parent: tree, elem: e, title: e.text(), children: [], level: lvl}
          else
            parent = findParent(last, lvl)
            parent.children.push {parent: parent, elem: e, title: e.text(), children: [], level: lvl}    

    visitNode = (node) ->
      classVal  = _.template(options.itemClass, {level: node.level, title: node.title})
      classAttr = " class='#{classVal}'" unless _.isEmpty(classVal)  
      res = $("<#{options.itemElem}#{classAttr or ''}><a href='#{options.anchorFn(node.elem)}'>#{node.title}</a></#{options.itemElem}>")

      if node.children.length
        classVal  = _.template(options.listClass, {level: node.level, title: node.title})
        classAttr = " class='#{classVal}'" unless _.isEmpty(classVal)  
        ul = $("<#{options.listElem}#{classAttr or ''} />")
        
        node.children.forEach (child) ->
          ul.append(visitNode(child))
      
        res.append(ul)

      res

    tree.children.forEach (child) ->
      target.append(visitNode(child))

    done(null, $.html());

module.exports = Renderer