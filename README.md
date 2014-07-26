mastermind-api
==============
The rules of Mastermind: http://en.wikipedia.org/wiki/Mastermind_(board_game)
 

This API is currently deployed on heroku: http://eric-mastermind.herokuapp.com/

There are only two endpoints for this api:

`POST /new_game`

This endpoint requires you to post with a `user` field. The response will be:
```json
{
    "game_key": "EryrN7000jMs750vYWKagKm11tkHgtHELdYBAKDt-VaKpKWz4KL-Uu7r0X8HQRWpDvw",
    "num_guesses": 0,
    "past_guesses": [],
    "past_results": []
}
```
Every subsequent post request will require you to supply the `game_key` field.

`POST /guess`

This endpoint requires you to post with the `game_key` and a `code` consisting of 4 letters of RBGYOP (corresponding to Red, Blue, Green, Yellow, Orange, Purple). The response will be:
```json
{
    "game_key": "EryrN7000jMs750vYWKagKm11tkHgtHELdYBAKDt-VaKpKWz4KL-Uu7r0X8HQRWpDvw",
    "num_guesses": 1,
    "past_guesses": [
        "BBBB"
    ],
    "past_results": [
        [
            0,
            0
        ]
    ],
    "guess": "BBBB",
    "result": [
        "You got 0 exact!",
        "You got 0 near!"
    ]
}
```

Once you guess the correct code you will receive the time it took for you to complete the challenge:
```json
{
    "user": "Eric",
    "game_key": "EryrN7000jMs750vYWKagKm11tkHgtHELdYBAKDt-VaKpKWz4KL-Uu7r0X8HQRWpDvw",
    "num_guesses": 2,
    "past_guesses": [
        "BBBB",
        "GGYO"
    ],
    "past_results": [
        [
            0,
            0
        ],
        [
            4,
            0
        ]
    ],
    "guess": "GGYO",
    "time_taken": 254.448826034,,
    "result": "You win!"
}
```
