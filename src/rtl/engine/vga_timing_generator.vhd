library ieee;
use ieee.std_logic_1164.all;

-- Module Generates Video Sync signals for Video Monitor Interface
-- RGB and Sync outputs tie directly to monitor connector pins
entity vga_timing_generator is
    generic (
        H_COUNT_MAX: integer := 800;
        V_COUNT_MAX: integer := 525
    );
    port(
        pixel_clock: in  std_logic;
        horiz_sync_out, vert_sync_out : out std_logic;
        video_on: out std_logic;
        pixel_row: out integer range 0 to V_COUNT_MAX;
        pixel_column: out integer range 0 to H_COUNT_MAX
     );
end vga_timing_generator;

architecture behavior of vga_timing_generator is
    -- Horizontal Timing constants
    constant H_PIXELS_COUNT:        integer := 640;
    constant H_FRONT_PORCH_LENGTH:  integer := 16;
    constant H_SYNC_PULSE_LENGTH:   integer := 96;
    constant H_COUNT_SYNC_LOW:      integer := H_PIXELS_COUNT + H_FRONT_PORCH_LENGTH;
    constant H_COUNT_SYNC_HIGH:     integer := H_COUNT_SYNC_LOW + H_SYNC_PULSE_LENGTH;

    -- Vertical Timing constants
    constant V_PIXELS_COUNT:        integer := 480;
    constant V_FRONT_PORCH_LENGTH:  integer := 9; -- 11;
    constant V_SYNC_PULSE_LENGTH:   integer := 2;
    constant V_COUNT_SYNC_LOW:      integer := V_PIXELS_COUNT + V_FRONT_PORCH_LENGTH;
    constant V_COUNT_SYNC_HIGH:     integer := V_COUNT_SYNC_LOW + V_SYNC_PULSE_LENGTH;

    signal horiz_sync, vert_sync: std_logic;
    signal video_on_v, video_on_h   : std_logic;
    signal h_count: integer range 0 to H_COUNT_MAX;
    signal v_count: integer range 0 to V_COUNT_MAX;

begin
    -- video_on is high only when RGB pixel data is being displayed
    -- used to blank color signals at screen edges during retrace
    video_on <= video_on_H and video_on_V;

    process
    begin
        wait until rising_edge(pixel_clock);
        --Generate Horizontal and Vertical Timing signals for Video signal
        -- H_count counts pixels (#pixels across + extra time for sync signals)
        --
        -- Horiz_sync ------------------------------------__________--------
        -- H_count 0 #pixels sync low end
        if (h_count = H_COUNT_MAX) then
            h_count <= 0;
        else
            h_count <= h_count + 1;
        end if;
        --Generate Horizontal Sync signal using H_count
        if (h_count <= H_COUNT_SYNC_HIGH) and (h_count >= H_COUNT_SYNC_LOW) then
            horiz_sync <= '0';
        else
            horiz_sync <= '1';
        end if;

        --V_count counts rows of pixels (#pixel rows down + extra time for V sync signal)
        --
        -- Vert_sync -----------------------------------------------_______------------
        -- V_count 0 last pixel row V sync low end
        --
        if (v_count >= V_COUNT_MAX) and (h_count >= H_COUNT_SYNC_LOW) then
            v_count <= 0;
        elsif (h_count = H_COUNT_SYNC_LOW) then
            v_count <= v_count + 1;
        end if;
        -- Generate Vertical Sync signal using V_count
        if (v_count <= V_COUNT_SYNC_HIGH) and (v_count >= V_COUNT_SYNC_LOW) then
            vert_sync <= '0';
        else
            vert_sync <= '1';
        end if;

        -- Generate Video on Screen signals for Pixel Data
        -- Video on = 1 indicates pixel are being displayed
        -- Video on = 0 retrace - user logic can update pixel
        -- memory without needing to read memory for display
        if (h_count < H_PIXELS_COUNT) then
            video_on_h   <= '1';
            pixel_column <= h_count;
        else
            video_on_h <= '0';
        end if;
        if (v_count <= V_PIXELS_COUNT) then
            video_on_v <= '1';
            pixel_row  <= v_count;
        else
            video_on_v <= '0';
        end if;

        -- Put all video signals through DFFs to eliminate any small timing
        -- delays that cause a blurry image
        horiz_sync_out <= horiz_sync;
        vert_sync_out  <= vert_sync;
    end process;
end Behavior;

