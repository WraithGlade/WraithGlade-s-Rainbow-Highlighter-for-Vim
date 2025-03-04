" WraithGlade's Rainbow Delimiter Highlighter for Vim
" ===================================================
" 
" What is this script?
" --------------------
" 
" Lisp/Scheme family languages use an indentation convention that (when
" combined with the abundance of nested delimiters they contain) can
" make it very difficult to see the corresponding matches parentheses, square
" brackets, and squiggly brackets. A 'rainbow highlighter' is simply
" any script or plugin that changes the colors of matching delimiters 
" so that each level of delimiters is colored differently for clarity.
" 
" Such highlighting can be very useful for Lisp/Scheme family programming
" languages especially, but is also useful in many other contexts too, such
" as unknown/obscure programming languages and even plain text (when nested).
" 
" 
" History and provenance
" ----------------------
" 
" This heavily modified script was built upon the 'RainbowParenthsis.vim' [sic] script 
" created and released by John Gilmore into the public domain on 2005-03-12.
" 
" I (internet alias: WraithGlade, website: WraithGlade.com) created this
" modified form (starting on 2024-09-20) out of frustration with a more prevalent and
" more 'modern' but more bloated and overengineered rainbow highlighting script.
" 
" So, I went back and found one of the oldest (most original) rainbow scripts and
" then revitalized, refurbished, and refined it to be usable in practice again.
" 
" This script also doesn't make any use of any 3rd party plugin systems, etc.
" It is designed to have few moving parts, few dependencies, and to be easy to understand.
" 
" Gilmore's original can be found at:
" 
"   https://www.vim.org/scripts/script.php?script_id=1230
" 
" I've modified Gilmore's script to be much more modular, intuitive, and practical
" and to have better default colors and such. I've added a lot of documentation too.
" 
" Thus, this script provides an alternative for anyone having issues with some 
" of the other rainbow highlighters out there or who just want a simpler system.
"
"
" How to use:
" -----------
"
" If you drop this file (rainbow.vim) into your ~/.vim/plugin (on Linux/BSD) or 
" %USERPROFILE%/vimfiles/plugin (on Windows) directory, it should autoload anytime 
" Vim starts, regardless of file type or language. If it doesn't, then perhaps try adding
" `filetype plugin on` somewhere to your `.vimrc` file (your user pref/config file).
" 
" Vim's `:source <path/to/rainbow.vim>` command can alternatively be used to load the script manually.
" 
" (PS: `:so` can be used as shorthand for `:source`, which is more convenient in practice.)
" 
" Anyway, I have organized the script into functions to enable simpler usage and customization.
" 
" You can call almost all of those functions manually when using Vim via `:call FuncName()`.
" I have provided 'command' versions of all the safe-to-reuse functions for shorthand use,
" which enables you to write just `:FuncName` in Vim instead of `:call FuncName()`.
" 
" (PS: Global function names must always begin with a capital letter in Vimscript.)
"
" This script can be restricted to only run for specific file types by
" modifying the `autocmd` lines for file extensions at the very end of this script.
" 
" Indeed, many things in this script are intended to be easily modifiable. Do so freely.
" I have added many comments to clarify what things are and alert you of pitfalls.
" 
" 
" To customize the behavior of the script:
" ----------------------------------------
"  
" The most common user modifications will likely be as follows:
" 
" Jump to the section labeled BASIC SETUP in the below Vimscript code.
" (Just type `/BASIC SETUP<Enter>` in Vim and you'll get there.)
"  
" Modify the script to call `RbDarkTheme()`, `RbLightTheme()`, or `RbHighContrast` by default 
" according to your preferences. For custom colors, the dark and light themes are more uniform 
" but the contrast gaps between successive colors are much smaller than in `RbHighContrast`.
" 
" Likewise, choose either `RbCustomColors()` or `RbNamedColors()`, whichever you prefer,
" and then ensure it is the one called in BASIC SETUP section below. Only one applies.
" `RbCustomColors()` is much more flexible though (it allows hex color codes) and is the default.
" 
" Experiment some and see what you prefer. There is always a tradeoff between consistency and contrast.
" Remember though that you can switch themes any time mid-session by calling the corresponding 
" command. This is especially useful via `:RbHi` for increasing contrast temporarily so that
" you can see in high contrast when needed and then set it back to something else afterwards.
" Try switching back and forth between `:RbDark` (or `:RbLight`) and `:RbHi` to see what I mean.
" 
" You can also call any of this script's functions at runtime by writing just `:FuncName` 
" during normal Vim use. There are also other shorthand versions and alt names available 
" (search for `command -narg` declarations to see what shorthand commands are already included).
" 
" The `:Rb` command is especially useful, since it toggles the rainbow highlighter on and off.
" Many other highly useful commands were included as well though. Take a look! Make your own too!
" 
" You can also modify the individual color assignments within the color theme functions
" to suit your prefrences, or create your own named color theme functions and call them.




" KNOWN BUGS AND LIMITATIONS:
" ---------------------------
" 
" - At nesting levels above 18, the syntax highlighting of closing delimiters 
"   may become mismatched! Such deep nesting is hard to understand regardless though.
" 
" - If `:syntax off` is used and then followed by `:syntax on` later,
"   then the rainbow highlighter may not turn back on. So, as a workaround, use 
"   the provided rainbow commands such as `:RbToggle`, `:RbOff`, and `:RbOn` instead.
"   I've often seen `:syntax off` followed by `:RbOn` work, but not `:syntax on`!
"   If you call `:syntax on` you may need to close and reopen the Vim editor to fix it.
"   
" - The color mode functions (`RbCustomColors` and `RbNamedColors`) break
"   things sometimes when called during normal Vim use *outside of this script*.
"   This is not much of a problem though: Color *themes* can still be switched easily.
"   There's not much reason why you'd want to change the color mode once you pick it.



" Color modes (named vs custom):
" ------------------------------

function! RbCustomColors()
  set termguicolors
  " Makes arbitrary colors (via `guifg=#hexcode`) active if TrueColor is supported.
  " 
  " See https://stackoverflow.com/questions/61832656/where-to-find-list-of-colors-for-vim 
  " (specifically https://stackoverflow.com/a/61833431) for more info.
endfunction
" Calling this function outside this script is known to break things sometimes.
" Thus, no shorthand `command` version is provided for it, to discourage errors.

function! RbNamedColors()
  set termguicolors&
  " Tells the highlighter to use the named (`ctermfg`) colors instead of the `guifg`s.
  " 
  " Only one set (`ctermfg` or `guifg`) applies at a given time!
endfunction
" Calling this function outside this script is known to break things sometimes.
" Thus, no shorthand `command` version is provided for it, to discourage errors.



" For understanding what the 'levels' are:
" ----------------------------------------
"
" IMPORTANT: 'level18c' is actually the FIRST (i.e. outermost) level of
" delimiters and hence will be the FIRST color to appear in use.
" 
" The numbering of levels is backwards relative to one's intuition.
" 
" Thus, a nested pair 18 levels deep is actually set by 'level1c', etc.
" 
" The highest numbered levels are the *outermost* delimiter pairs.
" 
" Gilmore's original script used 16 levels, but I changed it to 18 so that
" it became divisible by 6 because jumps in hue of less than 1/6 quickly
" become significantly harder to distinguish. Larger gaps are more legible.

" For choosing custom colors:
" ---------------------------
"
" `guifg` uses standard hexidecimal codes for red, green, and blue: `#RRGGBB`.
" Thus `#ff0000` is full red, `#00ff00` is full green, `#808080` is mid grey, etc.
" 
" The higher the contrast between foreground and background and between successive
" color hues, saturations, and lightnesses, the easier it'll be to distinguish deeply 
" nested nearby delimiters' matching pairs, but the more your choices will be
" forced to go a certain way. Thus, a good color theme is often a balancing act.



" For the default dark and light themes, I've set the colors for `guifg` mode to have 
" approximately equal luminosity via the HSLuv color model, which (unlike HSL) accounts 
" for human eyesight. I've evenly divided such colors 6x by hue, ~conserving luminosity.

function! RbDarkTheme()
  " Intended for dark backgrounds, thus assigns *light* foreground (fg) colors:
  "   `guifg` color formula: Rebelle HSLuv(20 + 60n, 255, 160) for n in 0..5
  "   where HSLuv(hue, saturation, luminosity) has max HSLuv(360, 255, 255)
  highlight level18c   ctermfg=LightRed         guifg=#ff6739
  highlight level17c   ctermfg=LightGreen       guifg=#a59b00
  highlight level16c   ctermfg=LightBlue        guifg=#00ae61
  highlight level15c   ctermfg=Yellow           guifg=#00a8b0
  highlight level14c   ctermfg=LightMagenta     guifg=#7591ff
  highlight level13c   ctermfg=LightCyan        guifg=#ff48df
  highlight level12c   ctermfg=LightRed         guifg=#ff6739
  highlight level11c   ctermfg=LightGreen       guifg=#a59b00
  highlight level10c   ctermfg=LightBlue        guifg=#00ae61
  highlight level9c    ctermfg=Yellow           guifg=#00a8b0
  highlight level8c    ctermfg=LightMagenta     guifg=#7591ff
  highlight level7c    ctermfg=LightCyan        guifg=#ff48df
  highlight level6c    ctermfg=LightRed         guifg=#ff6739
  highlight level5c    ctermfg=LightGreen       guifg=#a59b00
  highlight level4c    ctermfg=LightBlue        guifg=#00ae61
  highlight level3c    ctermfg=Yellow           guifg=#00a8b0
  highlight level2c    ctermfg=LightMagenta     guifg=#7591ff
  highlight level1c    ctermfg=LightCyan        guifg=#ff48df
endfunction
command -nargs=0 RbDarkTheme :call RbDarkTheme()
command -nargs=0 RbDark :call RbDarkTheme()
command -nargs=0 RbDarkBg :call RbDarkTheme()
command -nargs=0 RbLightFg :call RbDarkTheme()
" 'Fg' stands for 'foreground' color. 'Bg' stands for 'background' color.
" `:RbLightFg` is useful if you find the dark/light theme names confusing.

function! RbLightTheme()
  " Intended for light backgrounds, thus assigns *dark* foreground (fg) colors:
  "   `guifg` color formula: Rebelle HSLuv(20 + 60n, 255, 96) for n in 0..5
  "   where HSLuv(hue, saturation, luminosity) has max HSLuv(360, 255, 255)
  highlight level18c   ctermfg=DarkRed         guifg=#9f3400
  highlight level17c   ctermfg=DarkGreen       guifg=#615a00
  highlight level16c   ctermfg=DarkBlue        guifg=#006737
  highlight level15c   ctermfg=DarkYellow      guifg=#006368
  highlight level14c   ctermfg=DarkMagenta     guifg=#004fcb
  highlight level13c   ctermfg=DarkCyan        guifg=#a4008e
  highlight level12c   ctermfg=DarkRed         guifg=#9f3400
  highlight level11c   ctermfg=DarkGreen       guifg=#615a00
  highlight level10c   ctermfg=DarkBlue        guifg=#006737
  highlight level9c    ctermfg=DarkYellow      guifg=#006368
  highlight level8c    ctermfg=DarkMagenta     guifg=#004fcb
  highlight level7c    ctermfg=DarkCyan        guifg=#a4008e
  highlight level6c    ctermfg=DarkRed         guifg=#9f3400
  highlight level5c    ctermfg=DarkGreen       guifg=#615a00
  highlight level4c    ctermfg=DarkBlue        guifg=#006737
  highlight level3c    ctermfg=DarkYellow      guifg=#006368
  highlight level2c    ctermfg=DarkMagenta     guifg=#004fcb
  highlight level1c    ctermfg=DarkCyan        guifg=#a4008e
endfunction
command -nargs=0 RbLightTheme :call RbLightTheme()
command -nargs=0 RbLight :call RbLightTheme()
command -nargs=0 RbLightBg :call RbLightTheme()
command -nargs=0 RbDarkFg :call RbLightTheme()
" 'FG' stands for 'foreground' color. 'BG' stands for 'background' color.
" `:RbDarkFg` is useful if you find the dark/light theme names confusing.



" For the named `ctermfg` colors and high contrast theme, notice that I transition from
" blue to yellow instead of cyan. RGB CMY is more traditional but the contrast
" jump between blue and cyan is far harder to distinguish than the jump between
" blue and yellow (which are literally opposites). Thus, I use RGB YMC instead.
" For the `guifg` high contrast theme though, I adjusted the 'yellow' and 'magenta' 
" to more usable and pleasing colors (orange and purple instead, respectively).

function! RbHighContrast()
  " Intended for high color component contrast for easier discernment.
  " The `ctermfg` variant uses *actual* maximum component contrast, but the `guifg`
  " version tweaks the colors for aesthetics and so that the theme works better on both
  " dark and light backgrounds (though imperfectly, because of competing goals).
  highlight level18c   ctermfg=Red         guifg=#ff0000
  highlight level17c   ctermfg=Green       guifg=#00bf00
  highlight level16c   ctermfg=Blue        guifg=#0080ff
  highlight level15c   ctermfg=Yellow      guifg=#ff8000
  highlight level14c   ctermfg=Magenta     guifg=#8000ff
  highlight level13c   ctermfg=Cyan        guifg=#00bfbf
  highlight level12c   ctermfg=Red         guifg=#ff0000
  highlight level11c   ctermfg=Green       guifg=#00bf00
  highlight level10c   ctermfg=Blue        guifg=#0080ff
  highlight level9c    ctermfg=Yellow      guifg=#ff8000
  highlight level8c    ctermfg=Magenta     guifg=#8000ff
  highlight level7c    ctermfg=Cyan        guifg=#00bfbf
  highlight level6c    ctermfg=Red         guifg=#ff0000
  highlight level5c    ctermfg=Green       guifg=#00bf00
  highlight level4c    ctermfg=Blue        guifg=#0080ff
  highlight level3c    ctermfg=Yellow      guifg=#ff8000
  highlight level2c    ctermfg=Magenta     guifg=#8000ff
  highlight level1c    ctermfg=Cyan        guifg=#00bfbf
endfunction
command -nargs=0 RbHighContrast :call RbHighContrast()
command -nargs=0 RbHiContrast :call RbHighContrast()
command -nargs=0 RbHiCon :call RbHighContrast()
command -nargs=0 RbHigh :call RbHighContrast()
command -nargs=0 RbHi :call RbHighContrast()



" The 'white strobe' and 'black strobe' themes below are
" intended for the case where the mixing of the rainbow
" highlighter's colors and the already-existing syntax
" coloring of the language you are using conflict too
" strongly and you need something much more subtle. The
" contrast is much poorer than with the colors though,
" even when each gap is a full 1/3 of the greyscale axis
" per adjacent color jump, which is what I've done here.

function! RbWhiteStrobe()
  highlight level18c   ctermfg=White       guifg=#ffffff
  highlight level17c   ctermfg=LightGrey   guifg=#a8a8a8
  highlight level16c   ctermfg=Grey        guifg=#545454
  highlight level15c   ctermfg=White       guifg=#ffffff
  highlight level14c   ctermfg=LightGrey   guifg=#a8a8a8
  highlight level13c   ctermfg=Grey        guifg=#545454
  highlight level12c   ctermfg=White       guifg=#ffffff
  highlight level11c   ctermfg=LightGrey   guifg=#a8a8af
  highlight level10c   ctermfg=Grey        guifg=#545450
  highlight level9c    ctermfg=White       guifg=#ffffff
  highlight level8c    ctermfg=LightGrey   guifg=#a8a8af
  highlight level7c    ctermfg=Grey        guifg=#545450
  highlight level6c    ctermfg=White       guifg=#ffffff
  highlight level5c    ctermfg=LightGrey   guifg=#a8a8af
  highlight level4c    ctermfg=Grey        guifg=#545450
  highlight level3c    ctermfg=White       guifg=#ffffff
  highlight level2c    ctermfg=LightGrey   guifg=#a8a8af
  highlight level1c    ctermfg=Grey        guifg=#545450
endfunction
command -nargs=0 RbWhiteStrobe :call RbWhiteStrobe()
command -nargs=0 RbWhite :call RbWhiteStrobe()
command -nargs=0 RbWh :call RbWhiteStrobe()

function! RbBlackStrobe()
  highlight level18c   ctermfg=Black       guifg=#000000
  highlight level17c   ctermfg=DarkGrey    guifg=#545454
  highlight level16c   ctermfg=Grey        guifg=#a8a8a8
  highlight level15c   ctermfg=Black       guifg=#000000
  highlight level14c   ctermfg=DarkGrey    guifg=#545454
  highlight level13c   ctermfg=Grey        guifg=#a8a8a8
  highlight level12c   ctermfg=Black       guifg=#000000
  highlight level11c   ctermfg=DarkGrey    guifg=#545454
  highlight level10c   ctermfg=Grey        guifg=#a8a8a8
  highlight level9c    ctermfg=Black       guifg=#000000
  highlight level8c    ctermfg=DarkGrey    guifg=#545454
  highlight level7c    ctermfg=Grey        guifg=#a8a8a8
  highlight level6c    ctermfg=Black       guifg=#000000
  highlight level5c    ctermfg=DarkGrey    guifg=#545454
  highlight level4c    ctermfg=Grey        guifg=#a8a8a8
  highlight level3c    ctermfg=Black       guifg=#000000
  highlight level2c    ctermfg=DarkGrey    guifg=#545454
  highlight level1c    ctermfg=Grey        guifg=#a8a8a8
endfunction
command -nargs=0 RbBlackStrobe :call RbBlackStrobe()
command -nargs=0 RbBlack :call RbBlackStrobe()
command -nargs=0 RbBl :call RbBlackStrobe()



if !exists("g:RbActive")
  let g:RbActive = 0
endif
" This variable is (and should be) set to 1 whenever any rainbow syntax is applied.
" Otherwise, if you don't do that, then the `:Rb` toggle will need to be called 
" twice sometimes due to its state tracking getting out of sync with reality.
" Likewise is true (in reverse) for any functions that *clear* all rainbow syntax.
" I've 'coded defensively' in this respect, intentionally setting `g:RbActive` 
" redundantly in every relevant function. This also improves readability slightly.

function! RbParen()
  " The order of these declations matters. If you reverse them, it will break.
  syntax region level1 matchgroup=level1c start=/(/ end=/)/ contains=TOP,level1,level2,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level2 matchgroup=level2c start=/(/ end=/)/ contains=TOP,level2,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level3 matchgroup=level3c start=/(/ end=/)/ contains=TOP,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level4 matchgroup=level4c start=/(/ end=/)/ contains=TOP,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level5 matchgroup=level5c start=/(/ end=/)/ contains=TOP,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level6 matchgroup=level6c start=/(/ end=/)/ contains=TOP,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level7 matchgroup=level7c start=/(/ end=/)/ contains=TOP,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level8 matchgroup=level8c start=/(/ end=/)/ contains=TOP,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level9 matchgroup=level9c start=/(/ end=/)/ contains=TOP,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level10 matchgroup=level10c start=/(/ end=/)/ contains=TOP,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level11 matchgroup=level11c start=/(/ end=/)/ contains=TOP,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level12 matchgroup=level12c start=/(/ end=/)/ contains=TOP,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level13 matchgroup=level13c start=/(/ end=/)/ contains=TOP,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level14 matchgroup=level14c start=/(/ end=/)/ contains=TOP,level14,level15,level16,level17,level18,NoInParens
  syntax region level15 matchgroup=level15c start=/(/ end=/)/ contains=TOP,level15,level16,level17,level18,NoInParens
  syntax region level16 matchgroup=level16c start=/(/ end=/)/ contains=TOP,level16,level17,level18,NoInParens
  syntax region level17 matchgroup=level17c start=/(/ end=/)/ contains=TOP,level17,level18,NoInParens
  syntax region level18 matchgroup=level18c start=/(/ end=/)/ contains=TOP,level18,NoInParens
  let g:RbActive = 1
endfunction
command -nargs=0 RbParen :call RbParen()

function! RbSquare()
  " The order of these declations matters. If you reverse them, it will break.
  syntax region level1 matchgroup=level1c start=/\[/ end=/\]/ contains=TOP,level1,level2,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level2 matchgroup=level2c start=/\[/ end=/\]/ contains=TOP,level2,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level3 matchgroup=level3c start=/\[/ end=/\]/ contains=TOP,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level4 matchgroup=level4c start=/\[/ end=/\]/ contains=TOP,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level5 matchgroup=level5c start=/\[/ end=/\]/ contains=TOP,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level6 matchgroup=level6c start=/\[/ end=/\]/ contains=TOP,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level7 matchgroup=level7c start=/\[/ end=/\]/ contains=TOP,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level8 matchgroup=level8c start=/\[/ end=/\]/ contains=TOP,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level9 matchgroup=level9c start=/\[/ end=/\]/ contains=TOP,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level10 matchgroup=level10c start=/\[/ end=/\]/ contains=TOP,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level11 matchgroup=level11c start=/\[/ end=/\]/ contains=TOP,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level12 matchgroup=level12c start=/\[/ end=/\]/ contains=TOP,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level13 matchgroup=level13c start=/\[/ end=/\]/ contains=TOP,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level14 matchgroup=level14c start=/\[/ end=/\]/ contains=TOP,level14,level15,level16,level17,level18,NoInParens
  syntax region level15 matchgroup=level15c start=/\[/ end=/\]/ contains=TOP,level15,level16,level17,level18,NoInParens
  syntax region level16 matchgroup=level16c start=/\[/ end=/\]/ contains=TOP,level16,level17,level18,NoInParens
  syntax region level17 matchgroup=level17c start=/\[/ end=/\]/ contains=TOP,level17,level18,NoInParens
  syntax region level18 matchgroup=level18c start=/\[/ end=/\]/ contains=TOP,level18,NoInParens
  let g:RbActive = 1
endfunction
command -nargs=0 RbSquare :call RbSquare()

function! RbSquiggle()
  " The order of these declations matters. If you reverse them, it will break.
  syntax region level1 matchgroup=level1c start=/{/ end=/}/ contains=TOP,level1,level2,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level2 matchgroup=level2c start=/{/ end=/}/ contains=TOP,level2,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level3 matchgroup=level3c start=/{/ end=/}/ contains=TOP,level3,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level4 matchgroup=level4c start=/{/ end=/}/ contains=TOP,level4,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level5 matchgroup=level5c start=/{/ end=/}/ contains=TOP,level5,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level6 matchgroup=level6c start=/{/ end=/}/ contains=TOP,level6,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level7 matchgroup=level7c start=/{/ end=/}/ contains=TOP,level7,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level8 matchgroup=level8c start=/{/ end=/}/ contains=TOP,level8,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level9 matchgroup=level9c start=/{/ end=/}/ contains=TOP,level9,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level10 matchgroup=level10c start=/{/ end=/}/ contains=TOP,level10,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level11 matchgroup=level11c start=/{/ end=/}/ contains=TOP,level11,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level12 matchgroup=level12c start=/{/ end=/}/ contains=TOP,level12,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level13 matchgroup=level13c start=/{/ end=/}/ contains=TOP,level13,level14,level15,level16,level17,level18,NoInParens
  syntax region level14 matchgroup=level14c start=/{/ end=/}/ contains=TOP,level14,level15,level16,level17,level18,NoInParens
  syntax region level15 matchgroup=level15c start=/{/ end=/}/ contains=TOP,level15,level16,level17,level18,NoInParens
  syntax region level16 matchgroup=level16c start=/{/ end=/}/ contains=TOP,level16,level17,level18,NoInParens
  syntax region level17 matchgroup=level17c start=/{/ end=/}/ contains=TOP,level17,level18,NoInParens
  syntax region level18 matchgroup=level18c start=/{/ end=/}/ contains=TOP,level18,NoInParens
  let g:RbActive = 1
endfunction
command -nargs=0 RbSquiggle :call RbSquiggle()



function! RbOn()
  call RbParen()
  call RbSquare()
  call RbSquiggle()
  let g:RbActive = 1
endfunction
command -nargs=0 RbOn :call RbOn()

function! RbOff()
  syntax clear level18
  syntax clear level17
  syntax clear level16
  syntax clear level15
  syntax clear level14
  syntax clear level13
  syntax clear level12
  syntax clear level11
  syntax clear level10
  syntax clear level9
  syntax clear level8
  syntax clear level7
  syntax clear level6
  syntax clear level5
  syntax clear level4
  syntax clear level3
  syntax clear level2
  syntax clear level1
  let g:RbActive = 0
endfunction
command -nargs=0 RbOff :call RbOff()

" In order for delimiter coloring to be based on nesting levels instead of
" being separate per delimiter type, the various delimiters must share the
" same syntax groups. Thus, though (), [], and {} can be *enabled* separately
" they cannot be *disabled* separately (without employing workarounds).
" 
" However, here are the workarounds anyway, for your convenience:

function! RbOnlyParen()
  call RbOff()
  call RbParen()
  let g:RbActive = 1
endfunction
command -nargs=0 RbOnlyParen :call RbOnlyParen()
command -nargs=0 RbOParen :call RbOnlyParen()

function! RbOnlySquare()
  call RbOff()
  call RbSquare()
  let g:RbActive = 1
endfunction
command -nargs=0 RbOnlySquare :call RbOnlySquare()
command -nargs=0 RbOSquare :call RbOnlySquare()

function! RbOnlySquiggle()
  call RbOff()
  call RbSquiggle()
  let g:RbActive = 1
endfunction
command -nargs=0 RbOnlySquiggle :call RbOnlySquiggle()
command -nargs=0 RbOSquiggle :call RbOnlySquiggle()

function! RbOnlyParenSquare()
  call RbOff()
  call RbParen()
  call RbSquare()
  let g:RbActive = 1
endfunction
command -nargs=0 RbOnlyParenSquare :call RbOnlyParenSquare()
command -nargs=0 RbOParenSquare :call RbOnlyParenSquare()

function! RbOnlyParenSquiggle()
  call RbOff()
  call RbParen()
  call RbSquiggle()
  let g:RbActive = 1
endfunction
command -nargs=0 RbOnlyParenSquiggle :call RbOnlyParenSquiggle()
command -nargs=0 RbOParenSquiggle :call RbOnlyParenSquiggle()

function! RbOnlySquareSquiggle()
  call RbOff()
  call RbSquare()
  call RbSquiggle()
  let g:RbActive = 1
endfunction
command -nargs=0 RbOnlySquareSquiggle :call RbOnlySquareSquiggle()
command -nargs=0 RbOSquareSquiggle :call RbOnlySquareSquiggle()



" Function for toggling rainbow highlighting of delimiters on and off easily:
function! Rb()
  if g:RbActive ==# 0
    call RbOn()
    let g:RbActive = 1
  elseif g:RbActive ==# 1
    call RbOff()
    let g:RbActive = 0
  endif
endfunction
command -nargs=0 Rb :call Rb()
command -nargs=0 RbToggle :call Rb()
command -nargs=0 Rainbow :call Rb()
command -nargs=0 RainbowToggle :call Rb()
" Command names (like functions) must always start with capital letters, unfortunately.
" Thus, we can't shorten the rainbow toggle even more to `:rb`. Oh well though.



function! RbSync()
  if g:RbActive ==# 0
    call RbOff()
  elseif g:RbActive ==# 1
    call RbOn()
  endif
endfunction
command -nargs=0 RbSync :call RbSync()
" If the current rainbow highlighting state somehow doesn't 
" match the underlying state then this will synchronize them.

" One case where desynchronization of the highlighting happens is 
" whenever an unnamed buffer is saved to a named file in GVim. This fixes it:
augroup RbGVimFix
  autocmd!
  autocmd BufWritePost * call RbSync()
augroup end

" When Vim reloads a file that was modified outside of Vim (such as in a
" different text editor) then Vim will lose the applied rainbow highlighting.
" 
" The following `autocmd` group fixes that:
augroup RgFileReloadFix
  autocmd!
  autocmd FileChangedShellPost * call RbSync()
augroup end
" Thus, this fix makes working in parallel with both Vim and some other text
" editor open more pleasant. This is especially useful when the other editor doesn't 
" support rainbow highlighting itself but is very useful in other ways (e.g. DrRacket).
" 
" Using Vim with `rainbow.vim` active alongside whatever other editor(s) you
" use provides a very useful 'nesting level visualizer', plus access to Vim's
" editing commands! That way, you can easily get the best of both worlds!
" 
" Try it! Try working with both Vim and another editor side by side.
" Vim will detect changes and perform file reloads when they happen.
" 
" Note: The file changes are detected only when the Vim window regains focus.
" 
" Also: DrRacket is slower than Vim at detecting file changes, but DrRacket 
" can be forced to reload a file by pressing Ctrl Shift E. Thus, you can
" work in both directions (editing in DrRacket and Vim) more expediently.



" =====================================================================================
"   BASIC SETUP
" =====================================================================================

" Below is where everything is actually put into effect.
"
" This is the default setup for the script essentially.
" 
" If desired, modify the colors inside `RbDarkTheme` and/or `RbLightTheme` (etc)
" or alternatively create your own separate named color theme function(s).
" 
" Then, change which functions are called below to suit your preferences:

call RbCustomColors()
call RbHighContrast()

call RbOn()



" Set up file-type associations (or the lack thereof):
" ----------------------------------------------------

" Look for text of the form `*.file_extension` below.
" 
" Uncomment the lines for the file associations that you want to apply this script to.
" You may uncomment multiple this way. They apply separately, to all matching files.
" 
" Using just `*` causes the script to run for ALL file types and is the default.
" 
" `BufNewFile` means apply the script to new (unsaved) files.
" `BufRead` means apply the script to existing (saved) files.
" `GUIEnter` means apply the script to GVim and was necessary to fix a related GVim bug.

augroup RbFileAssociations
autocmd!
" Every use of `autocmd ...` is added as a separate instance, even if identical.
" 
" Hence, the `augroup ... autocmd!` idiom prevents *exponential growth* of redundant
" copies of `autocmd` instances if/when a script file is reloaded.


" To apply rainbow to ALL files types (including unspecified and/or unknown ones):

autocmd BufNewFile,BufRead,GUIEnter * source <sfile>

" WARNING: The below will have NO USEFUL EFFECT if the above line isn't commented out.


" For Common Lisp:
" ----------------
"autocmd BufNewFile,BufRead,GUIEnter *.lisp source <sfile>
"autocmd BufNewFile,BufRead,GUIEnter *.cl source <sfile>

" For Racket (the most popular Scheme-like language):
" ---------------------------------------------------
"autocmd BufNewFile,BufRead,GUIEnter *.rkt source <sfile>

" For various 'Scheme language standard adhering' languages or DSLs:
" ------------------------------------------------------------------
"autocmd BufNewFile,BufRead,GUIEnter *.scm source <sfile>
"autocmd BufNewFile,BufRead,GUIEnter *.ss source <sfile>
"autocmd BufNewFile,BufRead,GUIEnter *.sc source <sfile>
"autocmd BufNewFile,BufRead,GUIEnter *.sps source <sfile>
"autocmd BufNewFile,BufRead,GUIEnter *.sls source <sfile>
"autocmd BufNewFile,BufRead,GUIEnter *.sld source <sfile>
"autocmd BufNewFile,BufRead,GUIEnter *.scr source <sfile>
"autocmd BufNewFile,BufRead,GUIEnter *.sps7 source <sfile>
"autocmd BufNewFile,BufRead,GUIEnter *.scrbl source <sfile>

" Scheme is not well standardized and has no standard file extension.
" Indeed, the Scheme 'language standard' no longer has much influence.

" For Clojure:
" ------------
"autocmd BufNewFile,BufRead,GUIEnter *.clj source <sfile>
"autocmd BufNewFile,BufRead,GUIEnter *.cljs source <sfile>
"autocmd BufNewFile,BufRead,GUIEnter *.cljc source <sfile>

" `.clj` is for Clojure.
" `.cljs` is for ClojureScript.
" `.cljc` is for code that could be either Clojure or ClojureScript.

" For Janet:
" ----------
"autocmd BufNewFile,BufRead,GUIEnter *.janet so <sfile>

" For Fennel:
" ----------
"autocmd BufNewFile,BufRead,GUIEnter *.fnl so <sfile>

augroup end



" If you're having trouble deciding what language to use:
" -------------------------------------------------------

" Janet is a Lisp/Scheme family languages that cleans up and removes many
" oddities and archaisms from Lisp/Scheme (e.g. it has no `car` or `cdr`).
" However, it seems to be interpreted and intended for scripting/embedding and so
" it may suffer from poor performance on par with e.g. Python or non-JIT Lua (etc).

" Common Lisp seems to typically be the most performant *traditional* Lisp/Scheme language.
" One benchmark I looked at seemed to place CL's performance at ~3x to 6x slower than C (for SBCL).
" It used proper optimization declarations though. It was not 100% idiomatic Common Lisp code.
" 
" Steel Bank Common Lisp (SBCL) and Embeddable Common Lisp may be the most useful CL implementations.

" Racket and/or Janet are perhaps the 'cleanest' Lisp/Scheme languages overall.
" Racket has the nicest IDE, the easiest EXE generation, and one of the best macro debuggers.
" Janet 'breaks with past traditions' to improve idioms of use more than any of the others.

" Common Lisp and Racket probably have the largest libraries and largest communities.

" Some languages that transpile Lisp/Scheme-like code to *low-level* C also exist(!),
" such as Dale, CakeLisp, Wax, C-Mera, LISP/c (Lispsy), Lcc, and Carp.
" [Note: Even though Wax is inspired by Haxe, the correct spelling is 'Wax' -- not 'Waxe'.
" 
" These languages have smaller communities than Common Lisp and Racket and
" some appear less updated: either inactive (incomplete) or stable/mature (complete).
" 
" Such languages may require more low-level coding, but would likely easily greatly outperform 
" conventional Lisp/Scheme languages (including Common Lisp) and waste much less CPU time/energy.
" 
" You'll get access to closer binding to C and C's libraries, but may also *need* to do so.
" You'll produce far more computationally efficient programs that way though (~on par with C).

" Like many Lisp/Scheme family languages though, some of these languages don't have good
" cross-platform support for Windows, though nearly all support Linux/BSD/Unix well.
"
" Racket, Steel Bank Common Lisp, and Janet all of have very good Windows support.
" Other languages mentioned above may also, but I haven't tested them as much or at all.

" Fennel is another interesting Lisp/Scheme family lanuage. It transpiles to
" Lua and has full compatibility with it, which makes it possible to use
" Fennel anywhere where Lua is used (and Lua is the most popular overall
" embedded scripting language for applications in the software industry). 
" This makes Fennel a great option for 'using Lisp/Scheme anywhere'. 
" 
" Moreover, if the resulting code is run on LuaJIT then the performance is very good, 
" perhaps just modestly worse than something like Java or C#, hence perhaps as performant 
" as SBCL or faster. It is another good option, though less widely known.
" 
" It is compatible with basically any Lua codebase (e.g. the Love game engine, etc).

" See the following GitHub repo for a huge list of Lisp/Scheme languages and implementations:
" 
"   https://github.com/dundalek/awesome-lisp-languages 



" More file association implementation info:
" ------------------------------------------
"  
" `<sfile>` is the current script file (`rainbow.vim` in this case).
" 
" `source <path/to/file.vim>` loads and applies whatever `.vim` script is passed to it.
" `so` can be used as shorthand instead if desired.
"
" See https://vimdoc.sourceforge.net/htmldoc/autocmd.html
" 
" When I tried to put the above `autocmd` lines into separate
" function(s), it caused loading errors whenever I loaded
" `rainbow.vim` itself, and so I decided against that.
