module.exports = (ss)->
  everyauth = require 'everyauth'

  addAuth = ({service,id,secret,userId})->
    if service is 'twitter'
      everyauth[service]
        .consumerKey(id)
        .consumerSecret(secret)
    else
      everyauth[service]
        .appId(id)
        .appSecret(secret)

    if service is 'google'
      everyauth[service]
        .scope('https://www.googleapis.com/auth/userinfo.profile')

    everyauth[service]
      .findOrCreateUser( (session, accessToken, accessTokenSecret, data)->
        user = data[userId]

        console.log "\n\n#{service} login, #{user}\n\n"
        console.log data
        console.log "\n\n\n#{service} login, #{user}\n\n"

        #userId theft howto: use the same username on a different service
        session.userId = user
        session.save()
        true
      )
      .redirectPath '/'

  addAuth site for site in [
      service:'facebook'
      id:'414768235235232'
      secret:'5318eadb652e64066aac3caac1f5b923'
      userId:'username'
    ,
      service:'google'
      id:'462948734478-nr4k3hbhhr4t96bt67bfb46hlqan0dpi.apps.googleusercontent.com'
      secret:'xlKuQy0lR7oyPkgdH2phU_qq'
      userId:'name'
    ,
      service:'github'
      id:'78ce8d91eb2eff1450de'
      secret:'f2cf4c9f8be62cd3c44c1e604a2893b6690acbe7'
      userId:'login'
    ,
      service:'twitter'
      id:'zklMWtT9olHJPGlrtFLDDg'
      secret:'Ft6dWlZHMJ6Qcj9iaf8q33tLMxTtcwmGQLXqQJImpPQ'
      userId:'screen_name'
  ]

  ss.http.middleware.append everyauth.middleware()
