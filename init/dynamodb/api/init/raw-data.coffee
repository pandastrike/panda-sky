Data = ({to: {S, N}, merge}) ->
  raw = [
    {
      PlayerID: 101
      GameTitle: "Galaxy Invaders"
      TopScore: 5842
      Wins: 21
      Losses: 72
    },{
      PlayerID: 101
      GameTitle: "Meteror Blasters"
      TopScore: 1000
      Wins: 12
      Losses: 3
    },{
      PlayerID: 101
      GameTitle: "Starship X"
      TopScore: 24
      Wins: 4
      Losses: 9
    },{
      PlayerID: 102
      GameTitle: "Alien Adventure"
      TopScore: 192
      Wins: 32
      Losses: 192
    },{
      PlayerID: 102
      GameTitle: "Galaxy Invaders"
      TopScore: 0
      Wins: 0
      Losses: 5
    },{
      PlayerID: 103
      GameTitle: "Attack Ships"
      TopScore: 3
      Wins: 1
      Losses: 8
    },{
      PlayerID: 103
      GameTitle: "Galaxy Invaders"
      TopScore: 2317
      Wins: 40
      Losses: 3
    },{
      PlayerID: 103
      GameTitle: "Meteror Blasters"
      TopScore: 723
      Wins: 22
      Losses: 12
    },{
      PlayerID: 103
      GameTitle: "Starship X"
      TopScore: 42
      Wins: 4
      Losses: 19
    }
  ]

  for {PlayerID, GameTitle, TopScore, Wins, Losses} in raw
    merge S({PlayerID, GameTitle}), N({TopScore, Wins, Losses})

export default Data
