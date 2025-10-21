-- Returns a table of metadata key-value pairs for a document
function meta_table(document)
    local meta = {}
    for k, v in pairs(document.meta) do
      meta[k] = pandoc.utils.stringify(v)
    end
    return meta
end

return {
  ['opengraphcards'] = function(args, kwargs, meta, raw_args, context)
    local url = args[1]
    local mime, contents = pandoc.mediabag.fetch(url)
    local parsed = pandoc.read(contents, "html")
    local meta = meta_table(parsed)

    local show_title = kwargs["show_title"] ~= "false"
    local show_description = kwargs["show_description"] ~= "false"
    local show_image = kwargs["show_image"] ~= "false"

    local title = meta["title"] or meta["twitter:title"]
    local description = meta["description"] or meta["twitter:description"]
    local image = meta["twitter:image"]

    local card_div = pandoc.Div({}, pandoc.Attr("", {"card"}, {style = "max-width: 540px;"}))

    if show_image and image then
      local img = pandoc.Image({}, image, "", pandoc.Attr("", {"card-img-top"}, {style = "height: 100%; object-fit: cover;"}))
      card_div.content:insert(img)
    end

    local card_body = pandoc.Div({}, pandoc.Attr("", {"card-body"}, {}))
    card_div.content:insert(card_body)

    if show_title and title then
      local title_element = pandoc.Para({pandoc.Span(title, pandoc.Attr("", {"card-title", "h5"}, {}))})
      card_body.content:insert(title_element)
    end

    if show_description and description then
      local desc_element = pandoc.Para({pandoc.Span(description, pandoc.Attr("", {"card-text"}, {}))})
      card_body.content:insert(desc_element)
    end

    return card_div
  end
}
