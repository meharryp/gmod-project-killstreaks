AddCSLuaFile( "cl_init.lua" )
IncludeClientFile("cl_init.lua")
include( 'shared.lua' )

ENT.Sectors = {};
ENT.SearchSize = 0;

function ENT:MW2_Init()	

	self.MapBounds.xPos, self.MapBounds.xNeg = self:FindBounds(true);
	self.MapBounds.yPos, self.MapBounds.yNeg = self:FindBounds(false);
	self:SetupSectors();
	
	self:Helicopter_Init()
end

function ENT:Helicopter_Init()	
end
function ENT:SetupSectors()
	local x1, x2, y1, y2 = self.MapBounds.xPos, self.MapBounds.xNeg, self.MapBounds.yPos, self.MapBounds.yNeg;
	local tX, tY = 0, 0;
	local bool = true;
	while bool do
		tX, tY = 0, 0;
		x1 = self.MapBounds.xPos;
		while x1 >= x2 do
			
			if x1 - self.SearchSize >= x2 then
				tX = x1 - self.SearchSize;
			else
				tX = x2;
			end
			
			if y1 - self.SearchSize >= y2 then
				tY = y1 - self.SearchSize;
			else
				tY = y2;
				bool = false;
			end
			
			self:InitSector( x1, y1, tX, tY)
			
			x1 = x1 - self.SearchSize;
		end
		y1 = y1 - self.SearchSize;
	end
	
end
--[[
function ENT:SetupSectors()
	local x1, x2, y1, y2 = self.MapBounds.xPos, self.MapBounds.xNeg, self.MapBounds.yPos, self.MapBounds.yNeg;
	local tX, tY = 0, 0;
	local cap = 0;
	local pos, neg = true, true;
	while cap < 2 do
		if pos then
			if x1 - self.SearchSize >= 0 && y1 - self.SearchSize >= 0 then
				tX = x1; tY = y1;
				x1 = x1 - self.SearchSize; y1 = y1 - self.SearchSize;
				self:InitSector( tX, tY, x1, y1)
			else
				tX = x1; tY = y1;
				cap = cap + 1;
				pos = false;
			end
		end
		if neg then
			if x2 + self.SearchSize <= 0 && y2 + self.SearchSize <= 0 then
				tX = x2; tY = y2;
				x2 = x2 + self.SearchSize; y2 = y2 + self.SearchSize;
				self:InitSector( tX, tY, x2, y2)
			else
				tX = x2; tY = y2;
				cap = cap + 1;
				neg = false
			end
		end
	end
end
]]
function ENT:InitSector( x, y, x2, y2 )
	local sec = {}
	sec.x = x;
	sec.y = y;
	sec.x2 = x2;
	sec.y2 = y2;
	local midX = x - ( (x - x2) / 2)
	local midY = y - ( (y - y2) / 2)
	sec.MidPoint = {};
	sec.MidPoint.x = midX;
	sec.MidPoint.y = midY;
	table.insert( self.Sectors, sec);
end