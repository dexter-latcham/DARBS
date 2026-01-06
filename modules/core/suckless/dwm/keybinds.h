static const Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,			          				XK_d,      spawn,          {.v = (const char*[]){ "dmenu_run", NULL } } },
	{ MODKEY,                       XK_Return, spawn,          SHCMD(TERMINAL)},
	{ MODKEY|ShiftMask,             XK_Return, togglescratch,  {.ui=0}},
	{ MODKEY|ShiftMask,             XK_i, 		 togglescratch,  {.ui=1}},
	{ MODKEY|ShiftMask,             XK_b, 		 togglescratch,  {.ui=2}},

	{ MODKEY,             					XK_f,      togglefullscr,  {0} },
	{ MODKEY,                       XK_q,      killclient,     {0} },

	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_space,  zoom,      		 {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },

	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },

	{ MODKEY,                       XK_o,      incnmaster,     {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_o,      incnmaster,     {.i = -1 } },

	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },

	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },

	{ MODKEY,                       XK_Left,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_Right, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_Left,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_Right, tagmon,         {.i = +1 } },


	{ MODKEY,                       XK_z,  	  incrgaps,       {.i = +1 } },
	{ MODKEY,                       XK_x,  	  incrgaps,       {.i = -1 } },
	{ MODKEY,                       XK_a,  	  togglegaps,     {0}},
	{ MODKEY|ShiftMask,             XK_a,  	  defaultgaps,    {0}},





	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	//{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
};
