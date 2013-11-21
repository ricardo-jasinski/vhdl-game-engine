library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.float_pkg.all;
use work.tbu_text_out_pkg.all;

package tbu_assert_pkg is
    constant REAL_DELTA_MAX: real := 0.001;
    constant FLOAT_DELTA_MAX: real := 0.001;
    
    procedure assert_that(msg: string; expr: boolean);
    procedure assert_that(msg: string; expr: std_logic);
    procedure assert_that(msg: string; actual, expected: std_logic_vector);
    procedure assert_that(msg: string; actual, expected: unsigned);
    procedure assert_that(msg: string; actual, expected, tolerance: real := REAL_DELTA_MAX);
    procedure assert_that(msg: string; actual, expected: float; tolerance: real := FLOAT_DELTA_MAX);
    procedure describe(function_name: string);
    procedure should(msg: string; expr: boolean);

end;

package body tbu_assert_pkg is

    procedure assert_that(msg: string; expr: boolean) is begin
        assert expr report "error in test case '" & msg & "'" severity failure;
        put("- " & msg);
    end;

    procedure assert_that(msg: string; expr: std_logic) is begin
        assert_that(msg, ?? expr);
    end;

    function character_from_std_ulogic(value: std_ulogic) return character is
        type conversion_array_type is array (std_ulogic) of character;
        constant CONVERSION_ARRAY: conversion_array_type := (
            'U' => 'U', 'X' => 'X', '0' => '0', '1' => '1',
            'Z' => 'Z', 'W' => 'W', 'L' => 'L', 'H' => 'H', '-' => '-'
        );
    begin
        return CONVERSION_ARRAY(value);
    end;

    function string_from_std_logic_vector(vector : std_logic_vector) return string is
        variable vector_string : string(1 to vector'length);
    begin
        for i in vector'range loop
            vector_string(i + 1) := character_from_std_ulogic(vector(i));
        end loop;
        return vector_string;
    end;

    procedure assert_that(msg : string; actual, expected: std_logic_vector) is
    begin
        put("- " & msg);
        if (actual /= expected) then
            report "error in test case '" & msg & "'" & LF & "     " &
            "actual: " & string_from_std_logic_vector(actual) & ", " &
            "expected: " & string_from_std_logic_vector(expected)
            severity failure;
        end if;
    end procedure;

    procedure assert_that(msg : string; actual, expected: unsigned) is
    begin
        put("- " & msg);
        if (actual /= expected) then
            report "error in test case '" & msg & "'" & LF & "     " &
            "actual: " & to_string(actual) & ", " &
            "expected: " & to_string(expected)
            severity failure;
        end if;
    end procedure;

    procedure assert_that(msg : string; actual, expected, tolerance: real := REAL_DELTA_MAX) is begin
        put("- " & msg);
        
        -- we need to check with "<=" because the default comparison result for
        -- metavalues is 'false'; otherwise, whenever a value were 'X' the test would pass 
        if (abs(actual - expected) <= tolerance) then
            return;
        end if;
        
        report "error in test case '" & msg & "'" & LF & "     " &
            "actual: " & to_string(actual) & ", " &
            "expected: " & to_string(expected)
            severity failure;
    end procedure;

    procedure assert_that(msg: string; actual, expected: float; tolerance: real := FLOAT_DELTA_MAX) is begin
        put("- " & msg);

        -- we need to check with "<=" because the default comparison result for
        -- metavalues is 'false'; otherwise, whenever a value were 'X' the test would pass 
        if (abs(actual - expected) <= tolerance) then
            return;
        end if;
        
        report "error in test case '" & msg & "'" & LF & "     " &
            "actual: " & to_string(to_real(actual)) & ", " &
            "expected: " & to_string(to_real(expected))
            severity failure;
    end procedure;

    procedure describe(function_name: string) is begin
        put("Function " & function_name & " should:");
    end;

    procedure should(msg: string; expr: boolean) is begin
        assert expr report "error in test case '" & msg & "'" severity failure;
        put("- " & msg);
    end;

end;
