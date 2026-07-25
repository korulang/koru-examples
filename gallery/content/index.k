// content — the gallery's prose and data, out of the flow.
//
// These are VALUE tors, which is why they can live here at all: `110_021` blocks
// keyword tors (`cond`, `if`) as subflow heads inside a module, so the gallery's
// key vocabulary is stuck in the entry — but plain value tors modularise fine.
//
// Each blob is one physical line because koru has no multi-line string literal;
// moving them here at least keeps that out of the flow the reader is following.

pub tor catalog-items {} -> string
catalog-items -> "progress — ▌/░ meter, purple→pink\nspinner — MiniDot braille + tick\ntext-input — prompt, placeholder, blink\nlist — selection + ●/○ paginator\nviewport — scrollable content slice\npaginator — Dots + Arabic status chrome\nhelp — short • line / full column\ntable — header, pink row, … truncate\ntextarea — multi-line ┃ gutter + blink\ntimer / stopwatch — countdown + count-up\nfilepicker — path header, > pink, purple dirs\npager — composition: viewport + paginator\nstyle — Style fg/bg + UTF-8 runes"

pub tor dinner-items {} -> string
dinner-items -> "Ramen\nTomato Soup\nHamburgers\nCheeseburgers\nCurrywurst\nOkonomiyaki\nPasta\nFillet Mignon\nCaviar\nJust Wine\nTacos\nSushi\nPizza\nPho\nBibimbap\nPad Thai\nGyoza\nCroissant\nPaella\nFalafel\nBiryani\nSchnitzel\nEmpanadas\nKimchi Jjigae\nJollof Rice\nPierogi\nShakshuka\nMapo Tofu"

pub tor viewport-doc {} -> string
viewport-doc -> "The Viewport\n============\n\nA viewport is the simplest honest widget: a window onto\ncontent that does not fit. Everything else in a pager —\nthe title, the scroll position, the key hints — is chrome\naround this one idea: paint the slice, skip the rest.\n\n 1. The store owns the offset.\n 2. The widget owns the paint.\n 3. The keys mutate state, never pixels.\n\nThat separation is the whole design. When j bumps the\noffset, the next draw hands the viewport a new number and\nthe visible slice moves down one line. Nothing scrolls;\nthe world is repainted from state, every frame, and it is\nfast because the widget touches only the rows it shows.\n\nScrolling\n---------\n\nj or k moves one line. d and u jump half a page. g goes\nhome; G rides to the end — the last line parked at the\ntop of the window, the way less and vim leave it.\n\nLines longer than the window clip at the right edge rather than wrapping, which keeps columns honest and scanning calm — this line is deliberately long to prove it.\n\nClipping is not a compromise. Hard edges are what make a\nterminal feel solid: text never re-flows under your eyes,\nnever shifts a column while you read. Soft-wrap is a real\nfeature and it is deferred, not faked.\n\nThe End of the Content\n----------------------\n\nYou are near the bottom now. Past this point the window\nsimply runs out of lines to show, and the empty rows stay\nempty — no tildes, no filler, just the quiet edge of the\ncontent, which is the terminal's version of a margin.\n\n            · fin ·"

pub tor help-bindings {} -> string
help-bindings -> "↑/k:up\n↓/j:down\n←/h:prev page\n→/l:next page\ng:go to start\nG:go to end\n/:filter\n?:toggle help\nq:quit"

pub tor city-rows {} -> string
city-rows -> "1|Tokyo|Japan|37,274,000\n2|Delhi|India|32,065,760\n3|Shanghai|China|28,516,904\n4|Dhaka|Bangladesh|22,478,116\n5|São Paulo|Brazil|22,429,800\n6|Mexico City|Mexico|22,085,140\n7|Cairo|Egypt|21,750,020\n8|Beijing|China|21,333,332\n9|Mumbai|India|20,961,472\n10|Osaka|Japan|19,059,856\n11|Chongqing|China|16,874,740\n12|Karachi|Pakistan|16,839,950\n13|Istanbul|Turkey|15,636,243\n14|Kinshasa|DR Congo|15,628,085\n15|Lagos|Nigeria|15,387,639\n16|Buenos Aires|Argentina|15,369,919\n17|Kolkata|India|15,133,888\n18|Manila|Philippines|14,406,059\n19|Tianjin|China|13,589,078\n20|Guangzhou|China|13,301,532"

pub tor pager-doc {} -> string
pager-doc -> "PAGE ONE\n========\n\nA pager is two halves wired together.\nThe viewport shows one screen of a long\ndocument; the rows beneath are paginator\nchrome — Charm's status-only marker, in\nboth Dots and Arabic modes at once.\nOne store owns the page number. Press l:\nthis header, the visible lines, and both\nfooters jump in lockstep — shared state\ndriving two catalog leaves at once.\nPAGE TWO\n========\n\nThe viewport is honest about height. It\npaints only the rows its window holds and\nhard-clips long lines at the right edge\ninstead of re-flowing them, so columns\nstay still while you read. The host sees\nthe page index, not the window height, so\neach flip moves the offset by exactly\ntwelve lines — one fixed slice per page,\nclamped at both ends by the key guards.\nPAGE THREE\n==========\n\nTwo paginator modes, one source of truth.\nDots light the current page pink; Arabic\nprints N/M from the same store field, so\nthey can never disagree. That is the\ncomposition claim: leaves keep their own\npaint and chrome; the host keeps only\nthe numbers. This is the last page —\npress h to climb back through the deck\nand watch all three rows move together."
