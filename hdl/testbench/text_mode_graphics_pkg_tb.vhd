use work.text_mode_graphics_pkg.all;
use work.tbu_text_out_pkg.all;
use work.colors_pkg.all;

entity text_mode_graphics_pkg_tb is
end;

architecture testbench of text_mode_graphics_pkg_tb is
   
begin



    process begin
        for y in 0 to 11 loop
            for x in 0 to 79 loop
                --put( to_string(character_at_x_y(x,y)) );
                print( to_string(character_at_x_y(x,y)), newline => false );
            end loop;
            print("");
        end loop;
        
        for y in 0 to 11 loop
            for x in 0 to 79 loop
                --put( to_string(character_at_x_y(x,y)) );
                if text_pixel_at_x_y(x, y) then
                    print( "#", newline => false );
                else
                    print( " ", newline => false );
                end if;
            end loop;
            print("");
        end loop;

        
        std.env.finish;
    end process;

end;