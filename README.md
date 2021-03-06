mastermind-api
==============
The rules of Mastermind: http://en.wikipedia.org/wiki/Mastermind_(board_game)
 
This api uses 8 colors (RBGYOPCM) and 8 positions to guess.

This API is currently deployed on heroku: http://eric-mastermind.herokuapp.com/

The goal of this is to write an algorithm to get to the solution while interacting with the API. If this challenge is difficult (but not too difficult) we can post this on our AxiomZen website for the public to try out. Difficulty can be raised by increasing number of colors to choose from (currently 8 colors) or increasing number of spots to fill (currently set to 8)

There are only two endpoints for this api:

=========================
`POST /new_game`

This endpoint requires you to post with a `user` field.

Params:
```json
{
    "user: "Eric"
}
```

Response
```json
{
    "game_key": "niBpjqhujvM9NR0CQrB6e_xJXXWNNRLgfwYu8YPI3wpn4JdXs3ufRzOAv3SEC_0BNSw",
    "num_guesses": 0,
    "colors": ["R","B","G","Y","O","P","C","M"],
    "code_length": 8,
    "solved": "false",
    "past_results": []
}
```
Every subsequent post request will require you to supply the `game_key` field.

=======================
`POST /guess`

This endpoint requires you to post with the `game_key` and a `code` consisting of 5 letters of RBGYOP (corresponding to Red, Blue, Green, Yellow, Orange, Purple).

Params:
```json
{
    "game_key": "niBpjqhujvM9NR0CQrB6e_xJXXWNNRLgfwYu8YPI3wpn4JdXs3ufRzOAv3SEC_0BNSw",
    "code": "RPYGOGOP"
}
```

Response:
```json
{
    "game_key": "niBpjqhujvM9NR0CQrB6e_xJXXWNNRLgfwYu8YPI3wpn4JdXs3ufRzOAv3SEC_0BNSw",
    "num_guesses": 1,
    "colors": ["R","B","G","Y","O","P","C","M"],
    "code_length": 8,
    "past_results": [
        {
            "guess": "RPYGOGOP",
            "exact": 2,
            "near": 1
        }
    ],
    "solved": "false",
    "guess": "RPYGOGOP",
    "result": {
        "exact": 0,
        "near": 4
    }
}
```

Once you guess the correct code you will receive the time it took for you to complete the challenge:
```json
{
    "user": "Eric",
    "game_key": "jwrcZhiOn9Un6hBm0HnJqol8xpAGjznpGJ5A78EMqoxj-nG5vMouEJN58-l-CU0wP4M",
    "num_guesses": 2,
    "colors": ["R","B","G","Y","O","P","C","M"],
    "code_length": 8,
    "past_results": [
        {
            "guess": "RPYGOGOP",
            "exact": 0,
            "near": 4
        },
        {
            "guess": "POGPYCMO",
            "exact": 8,
            "near": 0
        }
    ],
    "solved": "true",
    "guess": "POGPYCMO",
    "time_taken": 64.75358,
    "result": "You win!"
}
```
