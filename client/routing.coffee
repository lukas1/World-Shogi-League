@Routes =
    home:
        path: '/'
        template: 'home'
        name: 'home'
    login:
        path: '/user/login',
        template: 'loginform'
    teamsEdit:
        path: '/teams/edit'
        template: 'teamsedit'
        name: 'teams.edit'
    updateUser:
        path: '/user/update'
        template: 'updateuser'
        name: 'user.update'
