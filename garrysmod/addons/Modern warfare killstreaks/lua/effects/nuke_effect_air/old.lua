
local matRefraction	= Material( "refract_ring" )
local matGlow = Material("sprites/light_glow02")

local SplodeSnd = Sound("ambient/explosions/explode_6.wav")
local WooshSnd = Sound("physics/nearmiss/whoosh_huge1.wav")

--local SplodeSnd = Sound("ambient/explosions/exp1-4.wav")

--ambient/levels/abs/electric_explosion3.wav

--ambient/wind/wind_hit1-3.wav

--physics/nearmiss/whoosh_huge1.wav
--physics/nearmiss/whoosh_huge2.wav

--physics/nearmiss/whoosh_large1.wav
--physics/nearmiss/whoosh_large4.wav

--ambient/levels/labs/teleport_preblast_suckin1.wav

--weapons/mortar/mortar_shell_incomming1.wav
--weapons/mortar/mortar_fire1.wav
--weapons/mortar/mortar_explode1-3.wav

--weapons/stinger_fire1.wav
function EFFECT:Init( data )
	
	self.Position = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	--self.Yield = data:GetScale()/100
	self.Yield = 1
	self.Yieldfast = self.Yield^1.4
	self.YieldSlow = self.Yield^0.75
	self.YieldSlowest = self.Yield^0.5
	
	local yield = self.Yield
	local yieldslow = self.YieldSlow
	local yieldslowest = self.YieldSlowest
	local yieldfast = self.Yieldfast
	local Pos = self.Position
	local Norm = Vector(0,0,1)
	
	Pos = Pos + Norm * 3
	
	self.TimeLeft = CurTime() + 14
	self.GAlpha = 254
	self.GSize = 100*yieldslow
	self.GHeight = 10
	self.Refract = 0
	self.Size = 24
	
	--sound
	surface.PlaySound(SplodeSnd)
	
	self.smokeparticles = {}
	self.dustparticles = {}
	self.dustfade = true
	local emitter = ParticleEmitter( Pos )
	
	--big firecloud
		for i=1, math.ceil(yieldfast*300) do
			
			local spawnpos = yieldslow*Vector(math.random(-400,400),math.random(-400,400),math.random(-280,350))
			--local particle = emitter:Add( "Effects/fire_cloud"..math.random(1,2), Pos + spawnpos)
			local particle = emitter:Add( "particles/flamelet"..math.random(1,5), Pos + spawnpos)
			spawnpos.z = math.random(180,260)
			local velvec = spawnpos:GetNormalized()
			local velmult = yieldslowest*math.random(128,192)
			particle:SetVelocity(velvec*velmult)
			particle:SetDieTime( math.Rand( 12, 14 ) )
			particle:SetStartAlpha( math.Rand(230, 250) )
			particle:SetStartSize( math.Rand( 64, 72 ) )
			particle:SetEndSize( math.Rand( 192, 256 ) )
			particle:SetRoll( math.Rand( 480, 540 ) )
			particle:SetRollDelta( math.random( -3, 3 ) )
			particle:SetColor(math.random(150,255), math.random(100,150), 100)
			particle:VelocityDecay( true )
		
		end

		
		--base explosion
		for i=1, math.ceil(yieldfast*384) do
			
			local spawnpos = yieldslow*Vector(math.random(-192,192),math.random(-192,192),math.random(-192,192))
			local particle = emitter:Add( "particles/flamelet"..math.random(1,5), Pos + spawnpos)
			local velvec = spawnpos:GetNormalized()
			local velmult = yieldslowest*math.random(800,1024)
			particle:SetVelocity(velvec*velmult)
			particle:SetDieTime( math.Rand( 2, 2.6 ) )
			particle:SetStartAlpha( math.Rand(210, 230) )
			particle:SetStartSize( math.Rand( 128, 192 ) )
			particle:SetEndSize( math.Rand( 256, 320 ) )
			particle:SetRoll( math.Rand( -80, 80 ) )
			particle:SetRollDelta( math.random( -1, 1 ) )
			particle:SetColor(math.random(150,255), math.random(100,150), 100)
			particle:VelocityDecay( true )
		
		end
		
		--fire plumes
		for i=1, math.ceil(yieldslowest*24) do
			
			local vecang = Vector(math.Rand(-8,8),math.Rand(-8,8),math.Rand(-8,8))
			local spawnpos = Pos + yieldslow*8*vecang
			
				for k=1,26 do
				local particle = emitter:Add( "particles/flamelet"..math.random(1,5), spawnpos + vecang*3*k)
				particle:SetVelocity(vecang*math.Rand(80 + 8*k,80 + 9*k))
				particle:SetDieTime( math.Rand( 1.7, 2.3 ) )
				particle:SetStartAlpha( math.Rand(230, 250) )
				particle:SetStartSize( k*math.Rand( 13, 15 ) )
				particle:SetEndSize( k*math.Rand( 17, 19 ) )
				particle:SetRoll( math.Rand( 20, 80 ) )
				particle:SetRollDelta( math.random( -1, 1 ) )
				particle:SetColor(math.random(150,255), math.random(100,150), 100)
				particle:VelocityDecay( true )
				end
		
		end
		
				
	-- big smoke cloud
		for i=1, math.ceil(yieldfast*300) do
			
			local spawnpos = yieldslow*Vector(math.random(-600,600),math.random(-600,600),math.random(-800,800))
			local particle = emitter:Add( "particles/smokey", Pos + spawnpos)
			spawnpos.z = math.random(600,700)
			local velvec = spawnpos:GetNormalized()
			local velmult = yieldslowest*math.random(60,74)
			local startalpha = math.Rand( 0, 6 )
			particle:SetVelocity(velvec*velmult)
			particle:SetLifeTime( math.Rand( -5, -3 ) )
			particle:SetDieTime( 20 )
			particle:SetStartAlpha( startalpha )
			particle:SetEndAlpha( 30 + startalpha )
			particle:SetStartSize( math.Rand( 200, 250 ) )
			particle:SetEndSize( 510 )
			particle:SetRoll( math.Rand( 480, 540 ) )
			particle:SetRollDelta( math.random( -1, 1 ) )
			particle:SetColor( 240, 240, 240 )
			particle:VelocityDecay( true )
			table.insert(self.smokeparticles,particle)
			
		end
		
		-- smoke ring
		for i=1, math.ceil(yield*256) do
			
			local vecang = Vector(math.Rand(-32,32),math.Rand(-32,32),0):GetNormalized()
			local spawnpos = Vector(math.Rand(-32,32),math.Rand(-32,32),math.Rand(-12,12)) + yieldslow*1400*vecang 
			local particle = emitter:Add( "particles/smokey", Pos + spawnpos)
			local startalpha = math.Rand( 0, 6 )
			vecang.z = 1.6
			particle:SetVelocity(yieldslowest*math.Rand(32,48)*vecang)
			particle:SetLifeTime( math.Rand( -5, -3 ) )
			particle:SetDieTime( 20 )
			particle:SetStartAlpha( startalpha )
			particle:SetEndAlpha( 30 + startalpha )
			particle:SetStartSize( math.Rand( 200, 250 ) )
			particle:SetEndSize( 510 )
			particle:SetRoll( math.Rand( 540, 600 ) )
			particle:SetRollDelta( math.random( -3, 3 ) )
			particle:SetColor( 240, 240, 240 )
			particle:VelocityDecay( true )
			table.insert(self.smokeparticles,particle)
			
		end
		
		

	emitter:Finish()
		
end

--THINK
-- Returning false makes the entity die
function EFFECT:Think( )
	local timeleft = self.TimeLeft - CurTime()
	if timeleft > 0 then 
	local ftime = FrameTime()
	
	self.GAlpha = self.GAlpha - 17*ftime
	self.GSize = self.GSize - 0.23*timeleft*ftime*self.YieldSlow
	self.GHeight = self.GHeight + 75*ftime*self.YieldSlowest
	
	self.Size = self.Size + 6000*ftime
	self.Refract = self.Refract + 1.5 * FrameTime()
		
	return true
	else
		for __,particle in pairs(self.smokeparticles) do
		particle:SetStartAlpha( 25 )
		particle:SetEndAlpha( 0 )
		end
	return false	
	end
end


-- Draw the effect
function EFFECT:Render()
local startpos = self.Position

matGlow:SetMaterialInt("$spriterendermode",9)
matGlow:SetMaterialInt("$ignorez",1)
matGlow:SetMaterialInt("$illumfactor",8)
matGlow:SetMaterialInt("$nocull",1)

render.SetMaterial(matGlow)  -- Sets the sprite's material 

--Base glow
render.DrawSprite(startpos + Vector(0,0,self.GHeight),120*self.GSize,70*self.GSize,Color(255,245,230,self.GAlpha))
render.DrawSprite(startpos + Vector(0,0,self.GHeight),230*self.GSize,230*self.GSize,Color(255,180,60,self.GAlpha))
--outer glow
render.DrawSprite(startpos,600*self.GSize,360*self.GSize,Color(250,80,10,0.9*self.GAlpha))

--shockwave
	if self.Size < 32768 then

		local Distance = EyePos():Distance( self.Entity:GetPos() )
		local Pos = self.Entity:GetPos() + (EyePos()-self.Entity:GetPos()):GetNormal() * Distance * (self.Refract^(0.3)) * 0.8

		matRefraction:SetMaterialFloat( "$refractamount", math.sin( self.Refract * math.pi ) * 0.1 )
		render.SetMaterial( matRefraction )
		render.UpdateRefractTexture()
		render.DrawSprite( Pos, self.Size, self.Size )

	end

end



