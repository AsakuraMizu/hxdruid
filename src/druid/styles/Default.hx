package druid.styles;

import druid.types.DruidStyle;

class Default {
    public static final style:DruidStyle = [
        "Button" => [
            "LONGTAP_TIME" => .4,
            "AUTOHOLD_TRIGGER" => .8,
            "DOUBLETAP_TIME" => .4,
            "on_set_enabled" => (button, node, state) -> {
                trace(button);
                trace(node);
                trace(state);
            }
        ]
    ];
}