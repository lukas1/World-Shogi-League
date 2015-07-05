Router.configure({
    layoutTemplate:"applicationLayout"
})

Router.route(Routes.home.path, (() ->
    this.render(Routes.home.template);
    )
    { name: Routes.home.name }
)

Router.route(Routes.login.path, () ->
    this.render(Routes.login.template);
)

Router.route(Routes.teamsEdit.path, (() ->
    this.render(Routes.teamsEdit.template);
    )
    { name: Routes.teamsEdit.name }
)

Router.route(Routes.updateUser.path, (() ->
    this.render(Routes.updateUser.template);
    )
    { name: Routes.updateUser.name }
)
