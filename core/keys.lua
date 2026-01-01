local K = {}
-- Our standard naming convention for naming our keys must begin with the `K.NAMESPACE`
------------------------------------------------------------
-- Namespace root
------------------------------------------------------------
K.NAMESPACE = "highlights_screensaver"

------------------------------------------------------------
-- Screensaver Message → Layout
------------------------------------------------------------
K.screensaver_message = {
    layout = {
        font_size = K.NAMESPACE .."_message_layout_font_size",
        line_spacing = K.NAMESPACE .."_message_layout_line_spacing",
        alignment = K.NAMESPACE .."_message_layout_alignment",
        padding = K.NAMESPACE .."_message_layout_padding",
        margin = K.NAMESPACE .."_message_layout_margin",
    },
}

------------------------------------------------------------
-- Future: Highlights Quote Layout (placeholder)
------------------------------------------------------------
K.highlights_quote = {
    layout = {
        font_size = K.NAMESPACE.."_quote_layout_font_size",
        line_spacing = K.NAMESPACE.."_quote_layout_line_spacing",
    },
}
return K
