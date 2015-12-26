sortOption = {sort: { points: -1 } }

Template.points.helpers
    teamsA: () ->
        Teams.find({class: "A"}, sortOption)
    teamsB: () ->
        Teams.find({class: "B"}, sortOption)
