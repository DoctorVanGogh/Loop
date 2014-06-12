-----------------------------------------------------------------------------------------------
-- Loop.multiple module repackaged for Wildstar by DoctorVanGogh
-----------------------------------------------------------------------------------------------
local MAJOR,MINOR = "DoctorVanGogh:Lib:Loop:Multiple", 1

-- Get a reference to the package information if any
local APkg = Apollo.GetPackage(MAJOR)
-- If there was an older version loaded we need to see if this is newer
if APkg and (APkg.nVersion or 0) >= MINOR then
	return -- no upgrade needed
end

--------------------------------------------------------------------------------
---------------------- ##       #####    #####   ######  -----------------------
---------------------- ##      ##   ##  ##   ##  ##   ## -----------------------
---------------------- ##      ##   ##  ##   ##  ######  -----------------------
---------------------- ##      ##   ##  ##   ##  ##      -----------------------
---------------------- ######   #####    #####   ##      -----------------------
----------------------                                   -----------------------
----------------------- Lua Object-Oriented Programming ------------------------
--------------------------------------------------------------------------------
-- Project: LOOP - Lua Object-Oriented Programming                            --
-- Release: 2.3 beta                                                          --
-- Title  : Multiple Inheritance Class Model                                  --
-- Author : Renato Maia <maia@inf.puc-rio.br>                                 --
--------------------------------------------------------------------------------
-- Exported API:                                                              --
--   class(class, ...)                                                        --
--   new(class, ...)                                                          --
--   classof(object)                                                          --
--   isclass(class)                                                           --
--   instanceof(object, class)                                                --
--   memberof(class, name)                                                    --
--   members(class)                                                           --
--   superclass(class)                                                        --
--   subclassof(class, super)                                                 --
--   supers(class)                                                            --
--------------------------------------------------------------------------------

local table = Apollo.GetPackage("DoctorVanGogh:Lib:Loop:Table").tPackage

local package = APkg and APkg.tPackage or {}

--------------------------------------------------------------------------------
local base = Apollo.GetPackage("DoctorVanGogh:Lib:Loop:Simple").tPackage 
--------------------------------------------------------------------------------
table.copy(base, package)
--------------------------------------------------------------------------------
local MultipleClass = {
	__call = new,
	__index = function (self, field)
		self = base.classof(self)
		for _, super in ipairs(self) do
			local value = super[field]
			if value ~= nil then return value end
		end
	end,
}

local function class(class, ...)
	if select("#", ...) > 1
		then return base.rawnew(table.copy(MultipleClass, {...}), initclass(class))
		else return base.class(class, ...)
	end
end
--------------------------------------------------------------------------------
local function isclass(class)
	local metaclass = base.classof(class)
	if metaclass then
		return metaclass.__index == MultipleClass.__index or
		       base.isclass(class)
	end
end
--------------------------------------------------------------------------------
local function superclass(class)
	local metaclass = base.classof(class)
	if metaclass then
		local indexer = metaclass.__index
		if (indexer == MultipleClass.__index)
			then return unpack(metaclass)
			else return metaclass.__index
		end
	end
end
--------------------------------------------------------------------------------
local function isingle(single, index)
	if single and not index then
		return 1, single
	end
end
local function supers(class)
	local metaclass = classof(class)
	if metaclass then
		local indexer = metaclass.__index
		if indexer == MultipleClass.__index
			then return ipairs(metaclass)
			else return isingle, indexer
		end
	end
	return isingle
end
--------------------------------------------------------------------------------
local function subclassof(class, super)
	if class == super then return true end
	for _, superclass in supers(class) do
		if subclassof(superclass, super) then return true end
	end
	return false
end
--------------------------------------------------------------------------------
local function instanceof(object, class)
	return subclassof(classof(object), class)
end


package.class = class
package.isclass = isclass
package.supers = supers
package.subclassof = subclassof
package.instanceof = instanceof

Apollo.RegisterPackage(package, MAJOR, MINOR, {})