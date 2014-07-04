url = require("url")

class Renderer
  render: (content, context, done) ->
    if not Renderer.host
      throw new Error('You must provide host setting in stacktic config to use sitemap plugin')
    
    res = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    res += "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">"

    context.$sitemapItems.forEach (i) ->
      loc = url.resolve(Renderer.host, i.$path)
      res += "<url><loc>#{loc}</loc>"
      res += "<lastmod>#{i.$lastmod}</lastmod>" if i.$lastmod
      res += "<changefreq>#{i.$changefreq}</changefreq>" if i.$changefreq
      res += "<priority>#{i.$priority}</priority>" if i.$priority
      res += "</url>"
      res
    res += "</urlset>"

    done null, res

module.exports = Renderer
