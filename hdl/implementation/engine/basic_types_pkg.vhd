library ieee;
use ieee.std_logic_1164.all;

-- This package is meant as a stop-gap solution while the boolean_vector type
-- specified in VHDL 2008 is not availabe in the used synthesis tools.
package basic_types_pkg is
    type bool_vector is array (natural range <>) of boolean;

    function std_logic_vector_from_bool_vector(bool_values: bool_vector) return std_logic_vector;
end;

package body basic_types_pkg is
    function std_logic_vector_from_bool_vector(bool_values: bool_vector) return std_logic_vector is
        variable slv_values: std_logic_vector(bool_values'range);
    begin
        for i in bool_values'range loop
            if bool_values(i) then
                slv_values(i) := '1';
            else
                slv_values(i) := '0';
            end if;
        end loop;
        return slv_values;
    end;
end;