library ieee;
use ieee.std_logic_1164.all;

package input_types_pkg is
    type input_buttons_type is record
        up, down, left, right: std_logic;
    end record;
end;
