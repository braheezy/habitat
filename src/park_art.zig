//! Original ASCII artwork for the park. Each frame is a static string, so
//! vaxis can borrow character slices safely until it renders the frame.
pub const sun =
    \\  \ | /
    \\ -- O --
    \\  / | \
;
pub const cloud =
    \\    .--.
    \\ .-(    ).
    \\(___.__)__)
;
pub const tree =
    \\       .-~~~~-.
    \\    .-~  o   ~-.
    \\   (  .    .    )
    \\  (   o  .   o   )
    \\   `-._  .  _.-'
    \\       |   |
    \\       |   |
    \\       |   |
    \\     __|   |__
;
pub const bench =
    \\  _______________
    \\ |_______________|
    \\ |_______________|
    \\    | |     | |
    \\    |_|     |_|
;
pub const kitten_sit =
    \\ /\_/\
    \\( o.o )
    \\ > ^ <
    \\ /   \~
    \\(__|__)
;
pub const kitten_walk_a =
    \\ /\_/\
    \\( o.o )___
    \\ > ^ <    )~
    \\   / /--/ /
;
pub const kitten_walk_b =
    \\ /\_/\
    \\( o.o )___
    \\ > ^ <    )~
    \\    /\  /\
;
pub const kitten_pounce =
    \\  /\_/\
    \\ ( >.< )__
    \\ / >o<    \__
    \\(__/    /\___)~
;
pub const kitten_sleep =
    \\  /\_/\  z
    \\ ( -.- ) z
    \\  > ^ <___
    \\ (________)~
;
// Small-screen alternates keep the same characters readable at 40x12.
pub const tiny_tree =
    \\ /\
    \\(())
    \\  ||
    \\ _||_
;
pub const tiny_bench =
    \\ _________
    \\|_________|
    \\  | | | |
;
pub const tiny_kitten_sit =
    \\ /\_/\
    \\( o.o )
    \\  > ^ <
;
pub const tiny_kitten_walk_a =
    \\ /\_/\
    \\( o.o )~
    \\  / \/
;
pub const tiny_kitten_walk_b =
    \\ /\_/\
    \\( o.o )~
    \\  \_/\
;
pub const tiny_kitten_pounce =
    \\ /\_/\
    \\( >.< )
    \\  / >o
;
pub const tiny_kitten_sleep =
    \\ /\_/\ z
    \\( -.- )
    \\  >_^<
;
pub const bird_perch =
    \\  ,_
    \\ (o)> 
    \\ /)  
    \\  ""
;
pub const bird_fly_a = "\\_o<";
pub const bird_fly_b = "/^o<";
pub const ball = "@";
pub const butterfly_a = "xXx";
pub const butterfly_b = ">x<";
pub const flower = ".*.";
pub const grass = "\"'.,'\"'.,'";

pub const tiny_bird_perch = "(o)>";
pub const tiny_butterfly_a = "xX";
pub const tiny_butterfly_b = ">x";
