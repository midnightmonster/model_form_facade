module SvelteHelper
  def svelte(name, props: {}, turbo_frame: nil, placeholder: "".html_safe, **attrs, &block)
    attrs["data-svelte-component"] = name
    attrs[:style] ||= "display: contents"
    if block
      snippet = capture(&block)
      if snippet&.strip&.present?
        props["children"] = {_snippet: snippet}
        placeholder = snippet.html_safe if placeholder == true
      end
    end
    script = tag.script(props.to_json.html_safe, type: "application/json")
    placeholder = tag.div(placeholder, style: "display: contents", data: {svelte_placeholder: true}) if placeholder.present?
    if turbo_frame
      turbo_frame_tag(turbo_frame, **attrs) { (placeholder || "".html_safe) + script }
    else
      tag.div((placeholder || "".html_safe) + script, **attrs)
    end
  end

  def svelte_form(name, form, props: nil, **attrs, &block)
    form_props = attrs.extract!(:action, :method)
    svelte(name, props: {
      **form.form_props,
      **(props || {}),
      **form_props
    }, **attrs, &block)
  end
end
