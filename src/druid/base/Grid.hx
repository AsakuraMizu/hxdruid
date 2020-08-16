package druid.base;

import defold.Gui;
import defold.Vmath;
import defold.types.Vector3;
import defold.types.Vector4;
import druid.types.NodeOrString;

/**
    Component to handle placing components by row and columns

    Grid can anchor your elements, get content size and other
**/
class Grid<T:{}> extends Component<T> {
    private var parent_node:GuiNode;
    private var in_row:Int;
    private var offset:Vector3 = Vmath.vector3();
    private var anchor:Vector3 = Vmath.vector3();
    private var node_size:Vector3 = Vmath.vector3();
    private var border:Vector4 = Vmath.vector4();
    private var border_offset:Vector3 = Vmath.vector3();

    /**
        List of all grid nodes
    **/
    public var grid_nodes(default, null):Array<GuiNode> = [];

    /**
        On item add callback
    **/
    public var on_add_item(default, null):Event<(T, GuiNode, Int) -> Void>;

    /**
        On item remove callback
    **/
    public var on_remove_item(default, null):Event<T -> Void>;

    /**
        On grid clear callback
    **/
    public var on_clear(default, null):Event<T -> Void>;

    /**
        On update item positions callback
    **/
    public var on_update_positions(default, null):Event<T -> Void>;

    /**
        Component constructor

        @param parent The gui node parent, where items will be placed
        @param element Element prefab. Need to get it size
        @param in_row How many nodes in row can be placed
    **/
    public function new(parent:NodeOrString, element:NodeOrString, ?in_row:Int = 1) {
        name = "Grid";

        parent_node = get_node(parent);
        var pivot = Const.PIVOTS[Gui.get_pivot(parent_node)];
        anchor = Vmath.vector3(0.5 + pivot.x, 0.5 - pivot.y, 0);

        this.in_row = in_row;
        node_size = Gui.get_size(get_node(element));

        on_add_item = new Event();
        on_remove_item = new Event();
        on_clear = new Event();
        on_update_positions = new Event();
    }

    private function check_border(pos:Vector3):Void {
        var border = border;
        var size = node_size;

        var W = pos.x - size.x/2 + border_offset.x;
        var E = pos.x + size.x/2 + border_offset.x;
        var N = pos.y + size.y/2 + border_offset.y;
        var S = pos.y - size.y/2 + border_offset.y;

        border.x = Math.min(border.x, W);
        border.y = Math.max(border.y, N);
        border.z = Math.max(border.z, E);
        border.w = Math.min(border.w, S);

        border_offset = Vmath.vector3(
            (border.x + (border.z - border.x) * anchor.x),
            (border.y + (border.w - border.y) * anchor.y),
            0
        );
    }

    private function get_pos(index:Int):Vector3 {
        var row = Math.ceil(index / in_row) - 1;
        var col = (index - row * in_row) - 1;
        return Vmath.vector3(
            col * (node_size.x + offset.x) - border_offset.x,
            -row * (node_size.y + offset.y) - border_offset.y,
            0
        );
    }

    private function update_pos():Void {
        for (i => v in grid_nodes.keyValueIterator())
            Gui.set_position(v, get_pos(i));

        on_update_positions.trigger([context]);
    }

    /**
        Set grid items offset, the distance between items

        @param offset Offset
    **/
    public function set_offset(offset:Vector3):Void {
        this.offset = offset;
        update_pos();
    }

    /**
        Set grid anchor

        @param acnhor Anchor
    **/
    public function set_anchor(anchor:Vector3):Void {
        this.anchor = anchor;
        update_pos();
    }

    /**
        Add new item to the grid

        @param item Gui node
        @param index The item position. By default add as last item
    **/
    public function add(item:NodeOrString, ?index:Int):Void {
        if (index == null)
            index = grid_nodes.length + 1;

        var node = get_node(item);
        grid_nodes.insert(index, node);
        Gui.set_parent(node, parent_node);

        var pos = get_pos(index);
        check_border(pos);
        update_pos();

        on_add_item.trigger([context, node, index]);
    }

    /**
        Return grid content size

        @return The grid content size
    **/
    public function get_size():Vector3
        return Vmath.vector3(
            border.z - border.x,
            border.y - border.w,
            0
        );

    /**
        Return array of all node positions

        @return All grid node positions
    **/
    public function get_all_pos():Array<Vector3>
        return [for (i in grid_nodes) Gui.get_position(i)];

    /**
        Clear grid nodes array. GUI nodes will be not deleted!
        If you want to delete GUI nodes, use grid.nodes array before grid:clear
    **/
    public function clear():Void {
        border.x = 0;
        border.y = 0;
        border.w = 0;
        border.z = 0;

        nodes = [];
    }
}