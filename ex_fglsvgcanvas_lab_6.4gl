-- Draw a Pie Chart instead of a Bar Chart
IMPORT util
IMPORT FGL fglsvgcanvas

CONSTANT MIN_VALUE = 100
CONSTANT MAX_VALUE = 500

DEFINE arr DYNAMIC ARRAY OF RECORD
    title STRING,
    value DECIMAL(11, 2),
    colour STRING
END RECORD
DEFINE chart STRING

DEFINE cid SMALLINT

MAIN
    DEFINE row_clicked INTEGER

    CLOSE WINDOW SCREEN
    DEFER INTERRUPT
    DEFER QUIT
    OPTIONS INPUT WRAP
    OPTIONS FIELD ORDER FORM

    CALL ui.Interface.loadStyles("ex_fglsvgcanvas_lab.4st")

    OPEN WINDOW w WITH FORM "ex_fglsvgcanvas_lab_6"

    DIALOG ATTRIBUTES(UNBUFFERED)
        INPUT ARRAY arr FROM scr.* ATTRIBUTES(WITHOUT DEFAULTS = TRUE)
            BEFORE INPUT
                CALL populate()
                CALL draw_chart()

        END INPUT

        INPUT BY NAME chart ATTRIBUTES(WITHOUT DEFAULTS = TRUE)
            ON ACTION select ATTRIBUTES(DEFAULTVIEW = NO)
                LET row_clicked = fglsvgcanvas.getItemId(cid)
                MESSAGE SFMT("%1 clicked, value = %2", arr[row_clicked].title, arr[row_clicked].value)
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

    DEFINE root_svg om.DomNode
    DEFINE n om.DomNode
    DEFINE defs om.DomNode
    DEFINE i INTEGER
    DEFINE attr DYNAMIC ARRAY OF om.SaxAttributes

    DEFINE total DECIMAL(11, 2)
    TYPE pointType RECORD
        x, y FLOAT
    END RECORD
    DEFINE p1, p2 pointType
    DEFINE arc, cum_arc FLOAT
    DEFINE path STRING
    
    CONSTANT SIZE = 1000
    CONSTANT MARGIN = 200
    CONSTANT RADIUS = 300

    -- Initialise
    CALL fglsvgcanvas.initialize()
    LET cid = fglsvgcanvas.create("formonly.chart")
    LET root_svg = fglsvgcanvas.setRootSVGAttributes(NULL, NULL, NULL, SFMT("0 0 %1 %1", SIZE), "xMidYMid meet")

    -- Define style for reuse
    LET attr[1] = om.SaxAttributes.create()
    CALL attr[1].addAttribute("fill", "black")
    CALL attr[1].addAttribute("font-family", "Times New Roman")
    CALL attr[1].addAttribute("text-anchor", "middle")
    CALL attr[1].addAttribute("font-size", "96px")

    -- Build list of styles
    LET defs = fglsvgcanvas.defs(NULL)
    CALL defs.appendChild(fglsvgcanvas.styleList(fglsvgcanvas.styleDefinition(".title", attr[1])))
    CALL root_svg.appendChild(defs)

    -- Add Title that uses this style
    LET n =
        fglsvgcanvas.text(
            SIZE / 2, MARGIN / 2 + 48, SFMT("Title as at %1", CURRENT HOUR TO SECOND),
            "title") -- Should be a style I can use instead of adding half font size
    CALL root_svg.appendChild(n)

    -- Circle boundary
    LET n = fglsvgcanvas.circle(SIZE / 2, SIZE / 2, RADIUS)
    CALL n.setAttribute(SVGATT_STYLE, 'stroke:black;fill:none') -- uses inline style
    CALL root_svg.appendChild(n)

    -- Calculate total
    LET total = 0
    FOR i = 1 TO arr.getLength()
        LET total = total + arr[i].value
    END FOR

    -- Add slice
    LET p1.x = SIZE / 2 + RADIUS
    LET p1.y = SIZE / 2
    LET cum_arc = 0.0

    FOR i = 1 TO arr.getLength()

        -- Calcualte degrees and end point
        LET arc = arr[i].value / total * 2 * util.Math.pi()
        LET cum_arc = cum_arc + arc
        LET p2.x = util.math.cos(cum_arc) * RADIUS + SIZE / 2
        LET p2.y = util.math.sin(cum_arc) * RADIUS + SIZE / 2

        LET path =
            SFMT("M %1 %2 A %3 %4 0 %7 1 %5 %6 L %8 %9",
                p1.x, p1.y, RADIUS, RADIUS, p2.x, p2.y, IIF(arc <= util.math.pi(), 0, 1), SIZE / 2, SIZE / 2)
        LET n = fglsvgcanvas.path(path)
        CALL n.setAttribute("id", i)
        CALL n.setAttribute(SVGATT_STYLE, SFMT("stroke:%1; fill: %1", arr[i].colour)) -- uses inline style
        CALL n.setAttribute(SVGATT_ONCLICK, SVGVAL_ELEM_CLICKED)
        CALL root_svg.appendChild(n)

        LET p1.x = p2.x
        LET p1.y = p2.y
    END FOR

    -- Draw
    CALL fglsvgcanvas.display(cid)

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
