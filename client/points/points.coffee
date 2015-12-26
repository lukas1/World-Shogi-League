sortOption = {sort: { points: -1 } }

Template.points.helpers
    pointsA: () ->
        teams = Teams.find({class: "A"}).fetch()
        points = 0
        points += team.points for team in teams
        return points
    pointsB: () ->
        teams = Teams.find({class: "B"}).fetch()
        points = 0
        points += team.points for team in teams
        return points
    teamsA: () ->
        Teams.find({class: "A"}, sortOption)
    teamsB: () ->
        Teams.find({class: "B"}, sortOption)
