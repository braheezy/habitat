//! Original Asciiquarium artwork, extracted from asciiquarium.perl 1.1.
//! Copyright (C) 2003 Kirk Baucom. GPL-2.0-or-later, as in the original.
//! Most ASCII art by Joan Stark; additional marine life by Claudio Matsuoka.
//!
//! Multiline strings are literal: backslashes here are visible characters.
//! Shapes and masks retain their original leading/trailing newlines. Mask
//! characters select colors at matching row/column positions; digits label
//! fish body parts for a per-fish palette. `?` marks transparent cells in
//! auto-transparent sprites. Ordinary spaces inside a body remain opaque.

pub const Sprite = struct {
    image: []const u8,
    mask: []const u8 = "",
};

pub const waterline_0 =
    \\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;

pub const waterline_1 =
    "^^^^ ^^^  ^^^   ^^^    ^^^^      ";

pub const waterline_2 =
    "^^^^      ^^^^     ^^^    ^^     ";

pub const waterline_3 =
    "^^      ^^^^      ^^^    ^^^^^^  ";

pub const waterline = [_][]const u8{ waterline_0, waterline_1, waterline_2, waterline_3 };

pub const castle_image =
    \\
    \\               T~~
    \\               |
    \\              /^\
    \\             /   \
    \\ _   _   _  /     \  _   _   _
    \\[ ]_[ ]_[ ]/ _   _ \[ ]_[ ]_[ ]
    \\|_=__-_ =_|_[ ]_[ ]_|_=-___-__|
    \\ | _- =  | =_ = _    |= _=   |
    \\ |= -[]  |- = _ =    |_-=_[] |
    \\ | =_    |= - ___    | =_ =  |
    \\ |=  []- |-  /| |\   |=_ =[] |
    \\ |- =_   | =| | | |  |- = -  |
    \\ |_______|__|_|_|_|__|_______|
    \\
;

pub const castle_mask =
    \\
    \\                RR
    \\
    \\              yyy
    \\             y   y
    \\            y     y
    \\           y       y
    \\
    \\
    \\
    \\              yyy
    \\             yy yy
    \\            y y y y
    \\            yyyyyyy
    \\
;

pub const castle: Sprite = .{ .image = castle_image, .mask = castle_mask };

pub const classic_fish_images_0 =
    \\
    \\       \
    \\     ...\..,
    \\\  /'       \
    \\ >=     (  ' >
    \\/  \      / /
    \\    `"'"'/''
    \\
;

pub const classic_fish_images_1 =
    \\
    \\      /
    \\  ,../...
    \\ /       '\  /
    \\< '  )     =<
    \\ \ \      /  \
    \\  `'\'"'"'
    \\
;

pub const classic_fish_images_2 =
    \\
    \\    \
    \\\ /--\
    \\>=  (o>
    \\/ \__/
    \\    /
    \\
;

pub const classic_fish_images_3 =
    \\
    \\  /
    \\ /--\ /
    \\<o)  =<
    \\ \__/ \
    \\  \
    \\
;

pub const classic_fish_images_4 =
    \\
    \\       \:.
    \\\;,   ,;\\\,,
    \\  \\\;;:::::::o
    \\  ///;;::::::::<
    \\ /;` ``/////``
    \\
;

pub const classic_fish_images_5 =
    \\
    \\      .:/
    \\   ,,///;,   ,;/
    \\ o:::::::;;///
    \\>::::::::;;\\\
    \\  ''\\\\\'' ';\
    \\
;

pub const classic_fish_images_6 =
    \\
    \\  __
    \\><_'>
    \\   '
    \\
;

pub const classic_fish_images_7 =
    \\
    \\ __
    \\<'_><
    \\ `
    \\
;

pub const classic_fish_images_8 =
    \\
    \\   ..\,
    \\>='   ('>
    \\  '''/''
    \\
;

pub const classic_fish_images_9 =
    \\
    \\  ,/..
    \\<')   `=<
    \\ ``\```
    \\
;

pub const classic_fish_images_10 =
    \\
    \\   \
    \\  / \
    \\>=_('>
    \\  \_/
    \\   /
    \\
;

pub const classic_fish_images_11 =
    \\
    \\  /
    \\ / \
    \\<')_=<
    \\ \_/
    \\  \
    \\
;

pub const classic_fish_images_12 =
    \\
    \\  ,\
    \\>=('>
    \\  '/
    \\
;

pub const classic_fish_images_13 =
    \\
    \\ /,
    \\<')=<
    \\ \`
    \\
;

pub const classic_fish_images_14 =
    \\
    \\  __
    \\\/ o\
    \\/\__/
    \\
;

pub const classic_fish_images_15 =
    \\
    \\ __
    \\/o \/
    \\\__/\
    \\
;

pub const classic_fish_images = [_][]const u8{ classic_fish_images_0, classic_fish_images_1, classic_fish_images_2, classic_fish_images_3, classic_fish_images_4, classic_fish_images_5, classic_fish_images_6, classic_fish_images_7, classic_fish_images_8, classic_fish_images_9, classic_fish_images_10, classic_fish_images_11, classic_fish_images_12, classic_fish_images_13, classic_fish_images_14, classic_fish_images_15 };

pub const classic_fish_masks_0 =
    \\
    \\       2
    \\     1112111
    \\6  11       1
    \\ 66     7  4 5
    \\6  1      3 1
    \\    11111311
    \\
;

pub const classic_fish_masks_1 =
    \\
    \\      2
    \\  1112111
    \\ 1       11  6
    \\5 4  7     66
    \\ 1 3      1  6
    \\  11311111
    \\
;

pub const classic_fish_masks_2 =
    \\
    \\    2
    \\6 1111
    \\66  745
    \\6 1111
    \\    3
    \\
;

pub const classic_fish_masks_3 =
    \\
    \\  2
    \\ 1111 6
    \\547  66
    \\ 1111 6
    \\  3
    \\
;

pub const classic_fish_masks_4 =
    \\
    \\       222
    \\666   1122211
    \\  6661111111114
    \\  66611111111115
    \\ 666 113333311
    \\
;

pub const classic_fish_masks_5 =
    \\
    \\      222
    \\   1122211   666
    \\ 4111111111666
    \\51111111111666
    \\  113333311 666
    \\
;

pub const classic_fish_masks_6 =
    \\
    \\  11
    \\61145
    \\   3
    \\
;

pub const classic_fish_masks_7 =
    \\
    \\ 11
    \\54116
    \\ 3
    \\
;

pub const classic_fish_masks_8 =
    \\
    \\   1121
    \\661   745
    \\  111311
    \\
;

pub const classic_fish_masks_9 =
    \\
    \\  1211
    \\547   166
    \\ 113111
    \\
;

pub const classic_fish_masks_10 =
    \\
    \\   2
    \\  1 1
    \\661745
    \\  111
    \\   3
    \\
;

pub const classic_fish_masks_11 =
    \\
    \\  2
    \\ 1 1
    \\547166
    \\ 111
    \\  3
    \\
;

pub const classic_fish_masks_12 =
    \\
    \\  12
    \\66745
    \\  13
    \\
;

pub const classic_fish_masks_13 =
    \\
    \\ 21
    \\54766
    \\ 31
    \\
;

pub const classic_fish_masks_14 =
    \\
    \\  11
    \\61 41
    \\61111
    \\
;

pub const classic_fish_masks_15 =
    \\
    \\ 11
    \\14 16
    \\11116
    \\
;

pub const classic_fish_masks = [_][]const u8{ classic_fish_masks_0, classic_fish_masks_1, classic_fish_masks_2, classic_fish_masks_3, classic_fish_masks_4, classic_fish_masks_5, classic_fish_masks_6, classic_fish_masks_7, classic_fish_masks_8, classic_fish_masks_9, classic_fish_masks_10, classic_fish_masks_11, classic_fish_masks_12, classic_fish_masks_13, classic_fish_masks_14, classic_fish_masks_15 };

pub const classic_fish = [_]Sprite{
    .{ .image = classic_fish_images[0], .mask = classic_fish_masks[0] },
    .{ .image = classic_fish_images[1], .mask = classic_fish_masks[1] },
    .{ .image = classic_fish_images[2], .mask = classic_fish_masks[2] },
    .{ .image = classic_fish_images[3], .mask = classic_fish_masks[3] },
    .{ .image = classic_fish_images[4], .mask = classic_fish_masks[4] },
    .{ .image = classic_fish_images[5], .mask = classic_fish_masks[5] },
    .{ .image = classic_fish_images[6], .mask = classic_fish_masks[6] },
    .{ .image = classic_fish_images[7], .mask = classic_fish_masks[7] },
    .{ .image = classic_fish_images[8], .mask = classic_fish_masks[8] },
    .{ .image = classic_fish_images[9], .mask = classic_fish_masks[9] },
    .{ .image = classic_fish_images[10], .mask = classic_fish_masks[10] },
    .{ .image = classic_fish_images[11], .mask = classic_fish_masks[11] },
    .{ .image = classic_fish_images[12], .mask = classic_fish_masks[12] },
    .{ .image = classic_fish_images[13], .mask = classic_fish_masks[13] },
    .{ .image = classic_fish_images[14], .mask = classic_fish_masks[14] },
    .{ .image = classic_fish_images[15], .mask = classic_fish_masks[15] },
};

pub const new_fish_images_0 =
    \\
    \\   \
    \\  / \
    \\>=_('>
    \\  \_/
    \\   /
    \\
;

pub const new_fish_images_1 =
    \\
    \\  /
    \\ / \
    \\<')_=<
    \\ \_/
    \\  \
    \\
;

pub const new_fish_images_2 =
    \\
    \\     ,
    \\     }\
    \\\  .'  `\
    \\}}<   ( 6>
    \\/  `,  .'
    \\     }/
    \\     '
    \\
;

pub const new_fish_images_3 =
    \\
    \\    ,
    \\   /{
    \\ /'  `.  /
    \\<6 )   >{{
    \\ `.  ,'  \
    \\   \{
    \\    `
    \\
;

pub const new_fish_images_4 =
    \\
    \\            \'`.
    \\             )  \
    \\(`.??????_.-`' ' '`-.
    \\ \ `.??.`        (o) \_
    \\  >  ><     (((       (
    \\ / .`??`._      /_|  /'
    \\(.`???????`-. _  _.-`
    \\            /__/'
    \\
    \\
;

pub const new_fish_images_5 =
    \\
    \\       .'`/
    \\      /  (
    \\  .-'` ` `'-._??????.')
    \\_/ (o)        '.??.' /
    \\)       )))     ><  <
    \\`\  |_\      _.'??'. \
    \\  '-._  _ .-'???????'.)
    \\      `\__\
    \\
;

pub const new_fish_images_6 =
    \\
    \\       ,--,_
    \\__    _\.---'-.
    \\\ '.-"     // o\
    \\/_.'-._    \\  /
    \\       `"--(/"`
    \\
;

pub const new_fish_images_7 =
    \\
    \\    _,--,
    \\ .-'---./_    __
    \\/o \\     "-.' /
    \\\  //    _.-'._\
    \\ `"\)--"`
    \\
;

pub const new_fish_images = [_][]const u8{ new_fish_images_0, new_fish_images_1, new_fish_images_2, new_fish_images_3, new_fish_images_4, new_fish_images_5, new_fish_images_6, new_fish_images_7 };

pub const new_fish_masks_0 =
    \\
    \\   1
    \\  1 1
    \\663745
    \\  111
    \\   3
    \\
;

pub const new_fish_masks_1 =
    \\
    \\  2
    \\ 111
    \\547366
    \\ 111
    \\  3
    \\
;

pub const new_fish_masks_2 =
    \\
    \\     2
    \\     22
    \\6  11  11
    \\661   7 45
    \\6  11  11
    \\     33
    \\     3
    \\
;

pub const new_fish_masks_3 =
    \\
    \\    2
    \\   22
    \\ 11  11  6
    \\54 7   166
    \\ 11  11  6
    \\   33
    \\    3
    \\
;

pub const new_fish_masks_4 =
    \\
    \\            1111
    \\             1  1
    \\111      11111 1 1111
    \\ 1 11  11        141 11
    \\  1  11     777       5
    \\ 1 11  111      333  11
    \\111       111 1  1111
    \\            11111
    \\
    \\
;

pub const new_fish_masks_5 =
    \\
    \\       1111
    \\      1  1
    \\  1111 1 11111      111
    \\11 141        11  11 1
    \\5       777     11  1
    \\11  333      111  11 1
    \\  1111  1 111       111
    \\      11111
    \\
;

pub const new_fish_masks_6 =
    \\
    \\       22222
    \\66    121111211
    \\6 6111     77 41
    \\6661111    77  1
    \\       11113311
    \\
;

pub const new_fish_masks_7 =
    \\
    \\    22222
    \\ 112111121    66
    \\14 77     1116 6
    \\1  77    1111666
    \\ 11331111
    \\
;

pub const new_fish_masks = [_][]const u8{ new_fish_masks_0, new_fish_masks_1, new_fish_masks_2, new_fish_masks_3, new_fish_masks_4, new_fish_masks_5, new_fish_masks_6, new_fish_masks_7 };

pub const new_fish = [_]Sprite{
    .{ .image = new_fish_images[0], .mask = new_fish_masks[0] },
    .{ .image = new_fish_images[1], .mask = new_fish_masks[1] },
    .{ .image = new_fish_images[2], .mask = new_fish_masks[2] },
    .{ .image = new_fish_images[3], .mask = new_fish_masks[3] },
    .{ .image = new_fish_images[4], .mask = new_fish_masks[4] },
    .{ .image = new_fish_images[5], .mask = new_fish_masks[5] },
    .{ .image = new_fish_images[6], .mask = new_fish_masks[6] },
    .{ .image = new_fish_images[7], .mask = new_fish_masks[7] },
};

pub const shark_images_0 =
    \\
    \\                              __
    \\                             ( `\
    \\  ,??????????????????????????)   `\
    \\;' `.????????????????????????(     `\__
    \\ ;   `.?????????????__..---''          `~~~~-._
    \\  `.   `.____...--''                       (b  `--._
    \\    >                     _.-'      .((      ._     )
    \\  .`.-`--...__         .-'     -.___.....-(|/|/|/|/'
    \\ ;.'?????????`. ...----`.___.',,,_______......---'
    \\ '???????????'-'
    \\
;

pub const shark_images_1 =
    \\
    \\                     __
    \\                    /' )
    \\                  /'   (??????????????????????????,
    \\              __/'     )????????????????????????.' `;
    \\      _.-~~~~'          ``---..__?????????????.'   ;
    \\ _.--'  b)                       ``--...____.'   .'
    \\(     _.      )).      `-._                     <
    \\ `\|\|\|\|)-.....___.-     `-.         __...--'-.'.
    \\   `---......_______,,,`.___.'----... .'?????????`.;
    \\                                     `-`???????????`
    \\
;

pub const shark_images = [_][]const u8{ shark_images_0, shark_images_1 };

pub const shark_masks_0 =
    "\n\n\n\n\n\n                                           cR\n \n                                          cWWWWWWWW\n\n\n";

pub const shark_masks_1 =
    \\
    \\
    \\
    \\
    \\
    \\
    \\        Rc
    \\
    \\  WWWWWWWWc
    \\
    \\
    \\
;

pub const shark_masks = [_][]const u8{ shark_masks_0, shark_masks_1 };

pub const shark = [_]Sprite{
    .{ .image = shark_images[0], .mask = shark_masks[0] },
    .{ .image = shark_images[1], .mask = shark_masks[1] },
};

pub const ship_images_0 =
    \\
    \\     |    |    |
    \\    )_)  )_)  )_)
    \\   )___))___))___)\
    \\  )____)____)_____)\\
    \\_____|____|____|____\\\__
    \\\                   /
    \\
;

pub const ship_images_1 =
    \\
    \\         |    |    |
    \\        (_(  (_(  (_(
    \\      /(___((___((___(
    \\    //(_____(____(____(
    \\__///____|____|____|_____
    \\    \                   /
    \\
;

pub const ship_images = [_][]const u8{ ship_images_0, ship_images_1 };

pub const ship_masks_0 =
    \\
    \\     y    y    y
    \\
    \\                  w
    \\                   ww
    \\yyyyyyyyyyyyyyyyyyyywwwyy
    \\y                   y
    \\
;

pub const ship_masks_1 =
    \\
    \\         y    y    y
    \\
    \\      w
    \\    ww
    \\yywwwyyyyyyyyyyyyyyyyyyyy
    \\    y                   y
    \\
;

pub const ship_masks = [_][]const u8{ ship_masks_0, ship_masks_1 };

pub const ship = [_]Sprite{
    .{ .image = ship_images[0], .mask = ship_masks[0] },
    .{ .image = ship_images[1], .mask = ship_masks[1] },
};

pub const whale_images_0 =
    \\
    \\        .-----:
    \\      .'       `.
    \\,????/       (o) \
    \\\`._/          ,__)
    \\
;

pub const whale_images_1 =
    \\
    \\    :-----.
    \\  .'       `.
    \\ / (o)       \????,
    \\(__,          \_.'/
    \\
;

pub const whale_images = [_][]const u8{ whale_images_0, whale_images_1 };

pub const whale_masks_0 =
    \\
    \\             C C
    \\           CCCCCCC
    \\           C  C  C
    \\        BBBBBBB
    \\      BB       BB
    \\B    B       BWB B
    \\BBBBB          BBBB
    \\
;

pub const whale_masks_1 =
    \\
    \\   C C
    \\ CCCCCCC
    \\ C  C  C
    \\    BBBBBBB
    \\  BB       BB
    \\ B BWB       B    B
    \\BBBB          BBBBB
    \\
;

pub const whale_masks = [_][]const u8{ whale_masks_0, whale_masks_1 };

pub const whale = [_]Sprite{
    .{ .image = whale_images[0], .mask = whale_masks[0] },
    .{ .image = whale_images[1], .mask = whale_masks[1] },
};

pub const classic_big_fish_images_0 =
    \\
    \\ ______
    \\`""-.  `````-----.....__
    \\     `.  .      .       `-.
    \\       :     .     .       `.
    \\ ,?????:   .    .          _ :
    \\: `.???:                  (@) `._
    \\ `. `..'     .     =`-.       .__)
    \\   ;     .        =  ~  :     .-"
    \\ .' .'`.   .    .  =.-'  `._ .'
    \\: .'???:               .   .'
    \\ '???.'  .    .     .   .-'
    \\   .'____....----''.'=.'
    \\   ""?????????????.'.'
    \\               ''"'`
    \\
;

pub const classic_big_fish_images_1 =
    \\
    \\                           ______
    \\          __.....-----'''''  .-""'
    \\       .-'       .      .  .'
    \\     .'       .     .     :
    \\    : _          .    .   :?????,
    \\ _.' (@)                  :???.' :
    \\(__.       .-'=     .     `..' .'
    \\ "-.     :  ~  =        .     ;
    \\   `. _.'  `-.=  .    .   .'`. `.
    \\     `.   .               :???`. :
    \\       `-.   .     .    .  `.???`
    \\          `.=`.``----....____`.
    \\            `.`.?????????????""
    \\              '`"``
    \\
;

pub const classic_big_fish_images = [_][]const u8{ classic_big_fish_images_0, classic_big_fish_images_1 };

pub const classic_big_fish_masks_0 =
    \\
    \\ 111111
    \\11111  11111111111111111
    \\     11  2      2       111
    \\       1     2     2       11
    \\ 1     1   2    2          1 1
    \\1 11   1                  1W1 111
    \\ 11 1111     2     1111       1111
    \\   1     2        1  1  1     111
    \\ 11 1111   2    2  1111  111 11
    \\1 11   1               2   11
    \\ 1   11  2    2     2   111
    \\   111111111111111111111
    \\   11             1111
    \\               11111
    \\
;

pub const classic_big_fish_masks_1 =
    \\
    \\                           111111
    \\          11111111111111111  11111
    \\       111       2      2  11
    \\     11       2     2     1
    \\    1 1          2    2   1     1
    \\ 111 1W1                  1   11 1
    \\1111       1111     2     1111 11
    \\ 111     1  1  1        2     1
    \\   11 111  1111  2    2   1111 11
    \\     11   2               1   11 1
    \\       111   2     2    2  11   1
    \\          111111111111111111111
    \\            1111             11
    \\              11111
    \\
;

pub const classic_big_fish_masks = [_][]const u8{ classic_big_fish_masks_0, classic_big_fish_masks_1 };

pub const classic_big_fish = [_]Sprite{
    .{ .image = classic_big_fish_images[0], .mask = classic_big_fish_masks[0] },
    .{ .image = classic_big_fish_images[1], .mask = classic_big_fish_masks[1] },
};

pub const new_big_fish_images_0 =
    \\
    \\                _ _ _
    \\             .='\ \ \`"=,
    \\           .'\ \ \ \ \ \ \
    \\\'=._?????/ \ \ \_\_\_\_\_\
    \\\'=._'.??/\ \,-"`- _ - _ - '-.
    \\  \`=._\|'.\/- _ - _ - _ - _- \
    \\  ;"= ._\=./_ -_ -_ {`"=_    @ \
    \\   ;="_-_=- _ -  _ - {"=_"-     \
    \\   ;_=_--_.,          {_.='   .-/
    \\  ;.="` / ';\        _.     _.-`
    \\  /_.='/ \/ /;._ _ _{.-;`/"`
    \\/._=_.'???'/ / / / /{.= /
    \\/.=' ??????`'./_/_.=`{_/
    \\
;

pub const new_big_fish_images_1 =
    \\
    \\            _ _ _
    \\        ,="`/ / /'=.
    \\       / / / / / / /'.
    \\      /_/_/_/_/_/ / / \?????_.='/
    \\   .-' - _ - _ -`"-,/ /\??.'_.='/
    \\  / -_ - _ - _ - _ -\/.'|/_.=`/
    \\ / @    _="`} _- _- _\.=/_. =";
    \\/     -"_="} - _  - _ -=_-_"=;
    \\\-.   '=._}          ,._--_=_;
    \\ `-._     ._        /;' \ `"=.;
    \\     `"\`;-.}_ _ _.;\ \/ \'=._\
    \\        \ =.}\ \ \ \ \'???'._=_.\
    \\         \_}`=._\_\.'`???????'=.\
    \\
;

pub const new_big_fish_images = [_][]const u8{ new_big_fish_images_0, new_big_fish_images_1 };

pub const new_big_fish_masks_0 =
    \\
    \\                1 1 1
    \\             1111 1 11111
    \\           111 1 1 1 1 1 1
    \\11111     1 1 1 11111111111
    \\1111111  11 111112 2 2 2 2 111
    \\  111111111112 2 2 2 2 2 2 22 1
    \\  111 1111 12 22 22 11111    W 1
    \\   11111112 2 2  2 2 111111     1
    \\   111111111          11111   111
    \\  11111 11111        11     1111
    \\  111111 11 1111 1 111111111
    \\1111111   11 1 1 1 1111 1
    \\1111       1111111111111
    \\
;

pub const new_big_fish_masks_1 =
    \\
    \\            1 1 1
    \\        11111 1 1111
    \\       1 1 1 1 1 1 111
    \\      11111111111 1 1 1     11111
    \\   111 2 2 2 2 211111 11  1111111
    \\  1 22 2 2 2 2 2 2 211111111111
    \\ 1 W    11111 22 22 2111111 111
    \\1     111111 2 2  2 2 21111111
    \\111   11111          111111111
    \\ 1111     11        111 1 11111
    \\     111111111 1 1111 11 111111
    \\        1 1111 1 1 1 11   1111111
    \\         1111111111111       1111
    \\
;

pub const new_big_fish_masks = [_][]const u8{ new_big_fish_masks_0, new_big_fish_masks_1 };

pub const new_big_fish = [_]Sprite{
    .{ .image = new_big_fish_images[0], .mask = new_big_fish_masks[0] },
    .{ .image = new_big_fish_images[1], .mask = new_big_fish_masks[1] },
};

pub const classic_monster_masks_0 =
    \\
    \\
    \\                                                            W
    \\
    \\
    \\
    \\
;

pub const classic_monster_masks_1 =
    \\
    \\
    \\     W
    \\
    \\
    \\
    \\
;

pub const classic_monster_masks = [_][]const u8{ classic_monster_masks_0, classic_monster_masks_1 };

pub const classic_monster_right_0 =
    \\
    \\                                                          ____
    \\            __??????????????????????????????????????????/   o  \
    \\          /    \????????_?????????????????????_???????/     ____ >
    \\  _??????|  __  |?????/   \????????_????????/   \????|     |
    \\ | \?????|  ||  |????|     |?????/   \?????|     |???|     |
    \\
;

pub const classic_monster_right_1 =
    \\
    \\                                                          ____
    \\                                             __?????????/   o  \
    \\             _?????????????????????_???????/    \?????/     ____ >
    \\   _???????/   \????????_????????/   \????|  __  |???|     |
    \\  | \?????|     |?????/   \?????|     |???|  ||  |???|     |
    \\
;

pub const classic_monster_right_2 =
    \\
    \\                                                          ____
    \\                                  __????????????????????/   o  \
    \\ _??????????????????????_???????/    \????????_???????/     ____ >
    \\| \??????????_????????/   \????|  __  |?????/   \????|     |
    \\ \ \???????/   \?????|     |???|  ||  |????|     |???|     |
    \\
;

pub const classic_monster_right_3 =
    \\
    \\                                                          ____
    \\                       __???????????????????????????????/   o  \
    \\  _??????????_???????/    \????????_??????????????????/     ____ >
    \\ | \???????/   \????|  __  |?????/   \????????_??????|     |
    \\  \ \?????|     |???|  ||  |????|     |?????/   \????|     |
    \\
;

pub const classic_monster_right = [_][]const u8{ classic_monster_right_0, classic_monster_right_1, classic_monster_right_2, classic_monster_right_3 };

pub const classic_monster_left_0 =
    \\
    \\    ____
    \\  /  o   \??????????????????????????????????????????__
    \\< ____     \???????_?????????????????????_????????/    \
    \\      |     |????/   \????????_????????/   \?????|  __  |??????_
    \\      |     |???|     |?????/   \?????|     |????|  ||  |?????/ |
    \\
;

pub const classic_monster_left_1 =
    \\
    \\    ____
    \\  /  o   \?????????__
    \\< ____     \?????/    \???????_?????????????????????_
    \\      |     |???|  __  |????/   \????????_????????/   \???????_
    \\      |     |???|  ||  |???|     |?????/   \?????|     |?????/ |
    \\
;

pub const classic_monster_left_2 =
    \\
    \\    ____
    \\  /  o   \????????????????????__
    \\< ____     \???????_????????/    \???????_??????????????????????_
    \\      |     |????/   \?????|  __  |????/   \????????_??????????/ |
    \\      |     |???|     |????|  ||  |???|     |?????/   \???????/ /
    \\
;

pub const classic_monster_left_3 =
    \\
    \\    ____
    \\  /  o   \???????????????????????????????__
    \\< ____     \??????????????????_????????/    \???????_??????????_
    \\      |     |??????_????????/   \?????|  __  |????/   \???????/ |
    \\      |     |????/   \?????|     |????|  ||  |???|     |?????/ /
    \\
;

pub const classic_monster_left = [_][]const u8{ classic_monster_left_0, classic_monster_left_1, classic_monster_left_2, classic_monster_left_3 };

pub const new_monster_masks_0 =
    \\                                                W W
    \\
    \\
    \\
    \\
;

pub const new_monster_masks_1 =
    \\
    \\   W W
    \\
    \\
    \\
    \\
;

pub const new_monster_masks = [_][]const u8{ new_monster_masks_0, new_monster_masks_1 };

pub const new_monster_right_0 =
    \\
    \\         _???_?????????????????????_???_???????_a_a
    \\       _{.`=`.}_??????_???_??????_{.`=`.}_????{/ ''\_
    \\ _????{.'  _  '.}????{.`'`.}????{.'  _  '.}??{|  ._oo)
    \\{ \??{/  .'?'.  \}??{/ .-. \}??{/  .'?'.  \}?{/  |
    \\
;

pub const new_monster_right_1 =
    \\
    \\                      _???_????????????????????_a_a
    \\  _??????_???_??????_{.`=`.}_??????_???_??????{/ ''\_
    \\ { \????{.`'`.}????{.'  _  '.}????{.`'`.}????{|  ._oo)
    \\  \ \??{/ .-. \}??{/  .'?'.  \}??{/ .-. \}???{/  |
    \\
;

pub const new_monster_right = [_][]const u8{ new_monster_right_0, new_monster_right_1 };

pub const new_monster_left_0 =
    \\
    \\   a_a_???????_???_?????????????????????_???_
    \\ _/'' \}????_{.`=`.}_??????_???_??????_{.`=`.}_
    \\(oo_.  |}??{.'  _  '.}????{.`'`.}????{.'  _  '.}????_
    \\    |  \}?{/  .'?'.  \}??{/ .-. \}??{/  .'?'.  \}??/ }
    \\
;

pub const new_monster_left_1 =
    \\
    \\   a_a_????????????????????_   _
    \\ _/'' \}??????_???_??????_{.`=`.}_??????_???_??????_
    \\(oo_.  |}????{.`'`.}????{.'  _  '.}????{.`'`.}????/ }
    \\    |  \}???{/ .-. \}??{/  .'?'.  \}??{/ .-. \}??/ /
    \\
;

pub const new_monster_left = [_][]const u8{ new_monster_left_0, new_monster_left_1 };

pub const splat_0 =
    \\
    \\
    \\   .
    \\  ***
    \\   '
    \\
    \\
;

pub const splat_1 =
    \\
    \\
    \\ ",*;`
    \\ "*,**
    \\ *"'~'
    \\
    \\
;

pub const splat_2 =
    \\
    \\  , ,
    \\ " ","'
    \\ *" *'"
    \\  " ; .
    \\
    \\
;

pub const splat_3 =
    \\
    \\* ' , ' `
    \\' ` * . '
    \\ ' `' ",'
    \\* ' " * .
    \\" * ', '
    \\
;

pub const splat = [_][]const u8{ splat_0, splat_1, splat_2, splat_3 };

pub const water_spout_0 =
    \\
    \\
    \\
    \\   :
    \\
;

pub const water_spout_1 =
    \\
    \\
    \\   :
    \\   :
    \\
;

pub const water_spout_2 =
    \\
    \\  . .
    \\  -:-
    \\   :
    \\
;

pub const water_spout_3 =
    \\
    \\  . .
    \\ .-:-.
    \\   :
    \\
;

pub const water_spout_4 =
    \\
    \\  . .
    \\'.-:-.`
    \\'  :  '
    \\
;

pub const water_spout_5 =
    \\
    \\
    \\ .- -.
    \\;  :  ;
    \\
;

pub const water_spout_6 =
    \\
    \\
    \\
    \\;     ;
    \\
;

pub const water_spout = [_][]const u8{ water_spout_0, water_spout_1, water_spout_2, water_spout_3, water_spout_4, water_spout_5, water_spout_6 };

pub const bubbles_0 =
    \\.
;

pub const bubbles_1 =
    \\o
;

pub const bubbles_2 =
    \\O
;

pub const bubbles_3 =
    \\O
;

pub const bubbles_4 =
    \\O
;

pub const bubbles = [_][]const u8{ bubbles_0, bubbles_1, bubbles_2, bubbles_3, bubbles_4 };

pub const teeth =
    \\*
;

pub const seaweed_0 =
    \\(
    \\ )
    \\(
    \\ )
    \\(
    \\ )
    \\
;

pub const seaweed_1 =
    \\ )
    \\(
    \\ )
    \\(
    \\ )
    \\(
    \\
;

pub const seaweed = [_][]const u8{ seaweed_0, seaweed_1 };

// Seaweed in Perl is generated by repeating these alternating rows, for
// heights 3 through 6. Select a prefix of either frame for shorter plants.
// Whale masks include three rows for the spout; prepend three blank rows
// to the body before composing a complete whale frame.
