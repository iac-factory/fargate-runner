/// 00 E ''         1A E $'\032'    34 - 4          4E - N          68 - h
/// 01 E $'\001'    1B E $'\E'      35 - 5          4F - O          69 - i
/// 02 E $'\002'    1C E $'\034'    36 - 6          50 - P          6A - j
/// 03 E $'\003'    1D E $'\035'    37 - 7          51 - Q          6B - k
/// 04 E $'\004'    1E E $'\036'    38 - 8          52 - R          6C - l
/// 05 E $'\005'    1F E $'\037'    39 - 9          53 - S          6D - m
/// 06 E $'\006'    20 E \          3A - :          54 - T          6E - n
/// 07 E $'\a'      21 E \!         3B E \;         55 - U          6F - o
/// 08 E $'\b'      22 E \"         3C E \<         56 - V          70 - p
/// 09 E $'\t'      23 E \#         3D - =          57 - W          71 - q
/// 0A E $'\n'      24 E \$         3E E \>         58 - X          72 - r
/// 0B E $'\v'      25 - %          3F E \?         59 - Y          73 - s
/// 0C E $'\f'      26 E \&         40 - @          5A - Z          74 - t
/// 0D E $'\r'      27 E \'         41 - A          5B E \[         75 - u
/// 0E E $'\016'    28 E \(         42 - B          5C E \\         76 - v
/// 0F E $'\017'    29 E \)         43 - C          5D E \]         77 - w
/// 10 E $'\020'    2A E \*         44 - D          5E E \^         78 - x
/// 11 E $'\021'    2B - +          45 - E          5F - _          79 - y
/// 12 E $'\022'    2C E \,         46 - F          60 E \`         7A - z
/// 13 E $'\023'    2D - -          47 - G          61 - a          7B E \{
/// 14 E $'\024'    2E - .          48 - H          62 - b          7C E \|
/// 15 E $'\025'    2F - /          49 - I          63 - c          7D E \}
/// 16 E $'\026'    30 - 0          4A - J          64 - d          7E E \~
/// 17 E $'\027'    31 - 1          4B - K          65 - e          7F E $'\177'
/// 18 E $'\030'    32 - 2          4C - L          66 - f
/// 19 E $'\031'    33 - 3          4D - M          67 - g

/***
#!/bin/bash
special=$'`!@#$%^&*()-_+={}|[]\\;\':",.<>?/ '
for ((i=0; i < ${#special}; i++)); do
    char="${special:i:1}"
    printf -v q_char '%q' "$char"
    if [[ "$char" != "$q_char" ]]; then
        printf 'Yes - character %s needs to be escaped\n' "$char"
    else
        printf 'No - character %s does not need to be escaped\n' "$char"
    fi
done | sort

>>> No - character % does not need to be escaped
>>> No - character + does not need to be escaped
>>> No - character - does not need to be escaped
>>> No - character . does not need to be escaped
>>> No - character / does not need to be escaped
>>> No - character : does not need to be escaped
>>> No - character = does not need to be escaped
>>> No - character @ does not need to be escaped
>>> No - character _ does not need to be escaped
*/

resource "random_password" "password" {
    count = var.password ? 1 : 0

    length = 32
    special = false
}
