-- Starting Point
IMPORT util

CONSTANT MIN_VALUE = 100
CONSTANT MAX_VALUE = 500

DEFINE arr DYNAMIC ARRAY OF RECORD
    title STRING,
    value DECIMAL(11, 2),
    colour STRING
END RECORD

MAIN
    CLOSE WINDOW SCREEN
    DEFER INTERRUPT
    DEFER QUIT
    OPTIONS INPUT WRAP
    OPTIONS FIELD ORDER FORM

    CALL ui.Interface.loadStyles("ex_fglsvgcanvas_lab.4st")

    OPEN WINDOW w WITH FORM "ex_fglsvgcanvas_lab_1"

    DIALOG ATTRIBUTES(UNBUFFERED)
        INPUT ARRAY arr FROM scr.* ATTRIBUTES(WITHOUT DEFAULTS = TRUE)
            BEFORE INPUT
                CALL populate()
                CALL draw_chart()

        END INPUT

        ON ACTION random ATTRIBUTES(TEXT = "Random")
            CALL populate()
            CALL draw_chart()

        ON ACTION redraw ATTRIBUTES(TEXT = "Draw")
            CALL draw_chart()

        ON ACTION close
            EXIT DIALOG
    END DIALOG

END MAIN

FUNCTION draw_chart()

    -- Code to draw chart will go here
END FUNCTION

FUNCTION populate()
    DEFINE i INTEGER

    FOR i = 1 TO 6
        CASE i
            WHEN 1
                LET arr[1].title = "Aaaaa"
                LET arr[1].colour = "red"
            WHEN 2
                LET arr[2].title = "Bbbbb"
                LET arr[2].colour = "orange"
            WHEN 3
                LET arr[3].title = "Ccccc"
                LET arr[3].colour = "yellow"
            WHEN 4
                LET arr[4].title = "Ddddd"
                LET arr[4].colour = "green"
            WHEN 5
                LET arr[5].title = "Eeeee"
                LET arr[5].colour = "blue"
            WHEN 6
                LET arr[6].title = "Fffff"
                LET arr[6].colour = "purple"
        END CASE

        LET arr[i].value = MIN_VALUE + util.Math.rand((MAX_VALUE - MIN_VALUE) * 100) / 100 -- random value
    END FOR
END FUNCTION