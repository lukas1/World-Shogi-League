Template.points.helpers
    pointsA: () ->
        teams = Teams.find({block: "A"}).fetch()
        points = 0
        points += team.points for team in teams
        return points
    pointsB: () ->
        teams = Teams.find({block: "B"}).fetch()
        points = 0
        points += team.points for team in teams
        return points
    teamsA: () ->
        Teams.find({block: "A"})
    teamsB: () ->
        Teams.find({block: "B"})