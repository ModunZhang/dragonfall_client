return function()
    local emitter = cc.ParticleSnow:createWithTotalParticles(4)
    emitter:setPositionType(2)
    emitter:setAngle(90)
    
    emitter:setPosVar(cc.p(40,0))
    
    emitter:setLife(1)
    emitter:setLifeVar(0)
    
    emitter:setGravity(cc.p(0,1))
    
    emitter:setSpeed(60)
    emitter:setSpeedVar(20)

    emitter:setStartSize(30)
    
    emitter:setStartColor(cc.c4f(1,1,1,1))
    emitter:setStartColorVar(cc.c4f(0,0,0,0.0))
    emitter:setEndColor(cc.c4f(1,1,1,0.1))

    emitter:setStartSpin(0)
    emitter:setStartSpinVar(100)
    emitter:setRotationIsDir(true)

    emitter:setTexture(cc.Director:getInstance():getTextureCache():addImage("lt.png"))
    emitter:setEmissionRate(emitter:getTotalParticles() / emitter:getLife())
    
    emitter:updateWithNoTime()
    return emitter
end

