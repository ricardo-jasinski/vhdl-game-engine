library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.colors_pkg.all;
use work.graphics_types_pkg.all;
use work.font_pkg.all;


package text_mode_pkg is

    -- Constrain text coordinates to optmize resources usage
    subtype text_coordinate_type is natural range 0 to 127;

    constant TEXT_ROWS_COUNT: text_coordinate_type := 25;
    constant TEXT_COLUMNS_COUNT: text_coordinate_type := 80;

    -- Define color for all on screen text
    constant TEXT_COLOR: palette_color_type := PC_WHITE;

    -- Representation of a text mode string shown on the screen
    type text_mode_string_type is record
        x: text_coordinate_type;
        y: text_coordinate_type;
        text: string(1 to 16);
        visible: boolean;
    end record;
    
    type text_mode_strings_type is array (natural range <>) of text_mode_string_type;

    function character_at_x_y(x, y: text_coordinate_type; strings: text_mode_strings_type) return character;
    function text_pixel_at_x_y(x, y: pixel_coordinate_type; strings: text_mode_strings_type) return boolean;
end;

package body text_mode_pkg is

    function character_at_x_y(x, y: text_coordinate_type; strings: text_mode_strings_type) return character is
    begin
        for i in strings'range loop
            if y = strings(i).y and x >= strings(i).x and x < strings(i).x + strings(i).text'length then
                return strings(i).text(x - strings(i).x + 1);
            end if;
        end loop;
        
        return ' ';
    end;

    -- Return true when
    function text_pixel_at_x_y(x, y: pixel_coordinate_type; strings: text_mode_strings_type) return boolean is
        variable char: character;
        variable ascii_code: natural range 0 to 127;
        variable glyph: glyph_type;

        variable x_unsigned: unsigned(10 downto 0);
        variable y_unsigned: unsigned(10 downto 0);

        variable glyph_x: unsigned(2 downto 0);
        variable glyph_y: unsigned(3 downto 0);

    begin
        char := character_at_x_y(x / FONT_WIDTH, y / FONT_HEIGHT, strings);
        ascii_code := character'pos(char);
        glyph := FONT_ROM(ascii_code);
        x_unsigned := to_unsigned(x, x_unsigned'length);
        y_unsigned := to_unsigned(y, y_unsigned'length);
        glyph_x := x_unsigned(glyph_x'range);
        glyph_y := y_unsigned(glyph_y'range);
        
        return glyph(to_integer(glyph_y))(to_integer(glyph_x)) = '1';
    end;
    
end;