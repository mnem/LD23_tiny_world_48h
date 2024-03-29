------------------------------------------------------------------------------
-- lef
--
-- A simple entity framework for lua.
--
-- For example usage, see examples.lua. To use this module in your
-- code, require it into a local variable:
--
--    local lef = require 'nah.lef'
--    lef.addEntityComponents('player', 'componentA', 'componentB')
--
-- Summary of module functions:
--
--    lef.registerComponentFactory(name, factory)
--
--    lef.addSystem(group, name, priority, processor[, ...component names])
--    lef.removeSystem(group[, name])
--    lef.updateSystem(group[, name])
--
--    lef.addEntityComponents(entity, ...)
--    lef.entityComponents(entity, ...)
--    lef.entitiesWithComponents(...)
--    lef.removeEntityComponents(entity, ...)
--    lef.destroyEntity(entity)
--
-- Components are generally simple tables of data. Component factories
-- are functions which return a new table with default values
-- for each data item in that table. For example:
--    lef.registerComponentFactory('position', function() return {x = 0, y = 0} end )
--    lef.registerComponentFactory('renderable', function() return {image = nil} end )
--
-- Entities are things which are associated with 1 or more components. Often
-- you will just want to use a string ID for an entity, but it could be
-- something more complex such as a table. When components are added to an
-- entity, the component factory is used to create a new instance of the
-- component data table for that entity. Example of creating and using
-- an entity:
--    lef.addEntityComponents('player', 'position', 'renderable', 'joystick')
--    lef.addEntityComponents('npc', 'position', 'renderable')
--    local pos, img = lef.entityComponents('player', 'position', 'renderable')
--
-- Systems process entities and update or otherwise react to data in the
-- entities components. Each system specifies which components and entity
-- must have into order for it to be processed by that system. Each time
-- updateSystem() is called for that system, the processor function is
-- given an array of entities to iterate over. Each entity in that array
-- is guaranteed to have at least the components specified by the system.
-- For example:
--    lef.addSystem('render', 'image render', 1, function(entities, lef)
--        for i, entity in ipairs(entities) do
--            local pos, img = lef.entityComponents(entity, 'position', 'renderable')
--            drawImage(pos.x, pos.y, img.image)
--        end
--    end, 'position', 'renderable')
--
--    lef.addSystem('logic', 'npc ai', 1, function(entities, lef)
--        for i, entity in ipairs(entities) do
--            local pos = lef.entityComponents(entity, 'position')
--            pos.x = pos.x + 1
--            pos.y = pos.y + 1
--        end
--    end, 'position', 'npc')
--
--    lef.addSystem('logic', 'read joystick', 1, function(entities, lef)
--        for i, entity in ipairs(entities) do
--            local pos = lef.entityComponents(entity, 'position')
--            pos.x = pos.x + getJoystickLeftRight()
--            pos.y = pos.y + getJoystickUpDown()
--        end
--    end, 'position', 'joystick')
--
--    lef.updateSystem('logic') -- Updates both systems in logic group
--    lef.updateSystem('render') -- Updates single system in render group
--
-- As you can see, systems have a name and belong to a group. This allows
-- you to update systems in a general order - for example 'input', 'ai',
-- 'physics' then render systems. If you don't care about the order
-- systems process entities, simple add them all to the same group
-- name and then update that group. When calling lef.updateSystem(), you
-- may also specify an exact system name if you only want that one updated.
--
------------------------------------------------------------------------------
--
-- (c) Copyright 2012 David Wagner.
--
-- Complain/commend: http://noiseandheat.com/
--
--
-- Licensed under the MIT license:
--
--     http://www.opensource.org/licenses/mit-license.php
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
------------------------------------------------------------------------------

-- Module exports
local M = {}

------------------------------------------------------------------------------
-- Public module variables ---------------------------------------------------
------------------------------------------------------------------------------

-- If true, warnings will cause an error
M.treatWarningsAsErrors = true

-- If true, prevents warnings printing the full stacktrace, unless they
-- are being treated as errors
M.supressWarningTraceback = false

-- Function to print messages.
M.print = print

------------------------------------------------------------------------------
-- Private module data -------------------------------------------------------
------------------------------------------------------------------------------

-- entities: hash (entity, componentInstances)
--   componentInstances: hash (componentName, componentInstance)
local entities = {}
local deadEntities = {}

-- systems: hash (group, groupSystems)
--   groupSystems: array
--     name: string
--     processor: function
--     componentNames: hash (componentName, true)
--     entities: array
--     entityMembership: hash (entity, true)
--     priority: number
local systems = {}

-- registeredComponentFactories: hash (componentName, factoryFunction)
local registeredComponentFactories = {}

------------------------------------------------------------------------------
-- Debugging and logging -----------------------------------------------------
------------------------------------------------------------------------------
local function warn(message, level)
    if M.treatWarningsAsErrors then
        error(message, level or 3)
    else
        if not M.supressWarningTraceback then
            M.print(debug.traceback("nah.entityframework WARNING: " .. message, level or 3))
        end
    end
end

------------------------------------------------------------------------------
-- Systems -------------------------------------------------------------------
------------------------------------------------------------------------------

local function entityComponentInstancesMatchComponentNames(entityComponentInstances, componentNames)
    for systemComponentName, _ in pairs(componentNames) do
        if entityComponentInstances[systemComponentName] == nil then
            return false
        end
    end

    return true
end

-- Updates the specified entity in all systems
local function updateSystemsWithEntity(entity)
    local belongs = false
    for group, groupSystems in pairs(systems) do
        for i, system in ipairs(groupSystems) do
            belongs = entityComponentInstancesMatchComponentNames(entities[entity], system.componentNames)
            if system.entityMembership[entity] ~= nil and belongs == false then
                -- Remove it
                for i, systemEntity in ipairs(system.entities) do
                    if systemEntity == entity then
                        table.remove(system.entities, i)
                        system.entityMembership[entity] = nil
                        break
                    end
                end
            end

            -- Add it if it belongs
            if belongs and system.entityMembership[entity] == nil then
                table.insert(system.entities, entity)
                system.entityMembership[entity] = true
            end
        end
    end
end

-- Updates the specified system with all entities
local function updateSystemWithEntities(system)
    system.entities = {}
    system.entityMembership = {}
    for entity, componentInstances in pairs(entities) do
        if entityComponentInstancesMatchComponentNames(componentInstances, system.componentNames) then
            table.insert(system.entities, entity)
            system.entityMembership[entity] = true
        end
    end
end

-- Adds a new system in the specified group which execute the specified
-- processor function over entities matching the named components listed
-- after the processor function. Larger priority numbers get processed
-- first
function M.addSystem(group, name, priority, processor, ...)
    if group == nil then warn('Cannot add a system with a nil group'); return end
    if name == nil then warn('Cannot add a system with a nil name'); return end
    if processor == nil then warn('Cannot add a system with a nil processor'); return end
    if priority == nil then warn('Cannot add a system with a nil priority'); return end

    M.removeSystem(group, name)

    local systemsGroup = systems[group] or {}
    local system = {
        name = name,
        processor = processor,
        componentNames = {},
        entities = {},
        entityMembership = {},
        priority = priority,
    }

    for i = 1, arg.n do
        system.componentNames[arg[i]] = true
    end

    table.insert(systemsGroup, system)
    -- Reverse sort.
    table.sort(systemsGroup, function(a, b) return a.priority > b.priority end)

    -- Add the system group back in case this was the first
    -- system in the group
    systems[group] = systemsGroup

    -- Populate the system with any existing entities
    updateSystemWithEntities(system)
end

-- Destroys a system if group and name are specified. If
-- only group is specified, destroys all systems in that group
function M.removeSystem(group, name)
    if group ~= nil then
        if name ~= nil then
            if systems[group] ~= nil then
                for i, system in ipairs(systems[group]) do
                    if system.name == name then
                        table.remove(systems[group], i)
                        return
                    end
                end
            end
        else
            systems[group] = nil
        end
    else
        warn("Tried to destroy a system, but group name was nil. You must specify at least the group name.")
    end
end

local function destroyDeadEntities()
    for entity, _ in pairs(deadEntities) do
        -- Wonder if we should teardown it's components?
        for group, groupSystems in pairs(systems) do
            for i, groupSystem in ipairs(groupSystems) do
                for j, systemEntity in ipairs(groupSystem.entities) do
                    if entity == systemEntity then
                        table.remove(groupSystem.entities, j)
                        groupSystem.entityMembership[entity] = nil
                    end
                end
            end
        end
        entities[entity] = nil
    end
    deadEntities = {}
end

-- Updates a system if group and name are specified. If
-- only group is specified, updates all systems in that group
function M.updateSystem(group, name)
    destroyDeadEntities()
    if group == nil then
        -- Update everything
        for group, systemsGroup in pairs(systems) do
            for i, system in ipairs(systemsGroup) do
                system.processor(system.entities, M)
                destroyDeadEntities()
            end
        end
    elseif name == nil then
        -- Update group
        if systems[group] ~= nil then
            for i, system in ipairs(systems[group]) do
                system.processor(system.entities, M)
                destroyDeadEntities()
            end
        end
    elseif systems[group] ~= nil then
        -- Update single system
        for i, system in ipairs(systems[group]) do
            if system.name == name then
                system.processor(system.entities, M)
                destroyDeadEntities()
                return
            end
        end
    end
end

-- Returns the total number of systems and the number of systems
-- in each group.
--
-- return totalCount, {groupName:groupSystemCount}
function M.systemCount()
    local totalCount = 0
    local groupCount = {}

    for groupName, groupSystems in pairs(systems) do
        groupCount[groupName] = 0
        for i, system in ipairs(groupSystems) do
            totalCount = totalCount + 1
            groupCount[groupName] = groupCount[groupName] + 1
        end
    end

    return totalCount, groupCount
end

-- Returns the total number of entities in each system
--
-- return { group: { name: count } }
function M.systemEntityCount()
    local counts = {}

    for groupName, groupSystems in pairs(systems) do
        counts[groupName] = {}
        for i, system in ipairs(groupSystems) do
            counts[groupName][system.name] = 0
            for j, entity in ipairs(system.entities) do
                if deadEntities[entity] == nil then
                    counts[groupName][system.name] = counts[groupName][system.name] + 1
                end
            end
        end
    end

    return counts
end

------------------------------------------------------------------------------
-- Components ----------------------------------------------------------------
------------------------------------------------------------------------------

-- Registers a new component factory under the given name. Names must be
-- unique.
--
-- Currently, there is no way to unregister a factory. This is because I'm
-- totally avoiding the issue where a new factory with the same name could
-- be then added which would produce a different component from that attached
-- to existing entities
function M.registerComponentFactory(name, factory)
    if registeredComponentFactories[name] == nil then
        registeredComponentFactories[name] = factory

        -- If any existing entities have a placeholder for this component,
        -- create them now
        for entity, componentInstances in pairs(entities) do
            if componentInstances[name] ~= nil then
                componentInstances[name] = factory()
            end
        end
    else
        if factory ~= registeredComponentFactories[name] then
            -- TODO: Decide if the factory should be replaced
            -- with the new one
            warn("Tried to replace a component factory. Haven't decided if this is supported yet.")
        end
    end
end

-- Returns the total number of component factories
--
-- return totalCount
function M.componentFactoryCount()
    local totalCount = 0

    for componentName, factoryFunction in pairs(registeredComponentFactories) do
        totalCount = totalCount + 1
    end

    return totalCount
end

------------------------------------------------------------------------------
-- Entity manipulation -------------------------------------------------------
------------------------------------------------------------------------------

-- Adds the specified components to the entity. The entity may be any object.
-- If it already has components, any new components that are specified
-- will be added to it.
--
-- returns the component instances specified for the entity.
function M.addEntityComponents(entity, ...)
    if entity == nil then
        warn('Cannot add components to nil entity.')
        return
    end

    local entityComponents = entities[entity] or {}
    local addedArray = {}
    local instance = nil
    local factory = nil
    local component = nil

    for i = 1, arg.n do
        component = arg[i]
        if entityComponents[component] == nil then
            factory = registeredComponentFactories[component] or function() return '__placeholder "' .. component .. '"' end
            instance = factory()
            entityComponents[component] = instance
        else
            instance = entityComponents[component]
        end
        table.insert(addedArray, instance)
    end

    -- add the components here so that the entity reference is
    -- actually created if it was a new one
    entities[entity] = entityComponents

    updateSystemsWithEntity(entity)

    return unpack(addedArray)
end

function M.entityComponents(entity, ...)
    local entityComponents = entities[entity] or {}
    local components = {}

    for i = 1, arg.n do
        table.insert(components, entityComponents[arg[i]])
    end

    return unpack(components)
end

function M.removeEntityComponents(entity, ...)
    local entityComponents = entities[entity] or {}
    local removedArray = {}

    for i = 1, arg.n do
        -- nil values can be inserted here, but that's OK so that
        -- the return values are in the expected order
        -- for the caller
        table.insert(removedArray, entityComponents[arg[i]])
        entityComponents[arg[i]] = nil
    end

    updateSystemsWithEntity(entity)

    return unpack(removedArray)
end

function M.destroyEntity(entity)
    deadEntities[entity] = true
end

-- Returns an array containing all entities with at least the
-- specified components
--
-- return array of entities
function M.entitiesWithComponents(...)
    local matching = {}
    local componentNames = {}

    for i = 1, arg.n do
        componentNames[arg[i]] = true
    end

    for entity, componentInstances in pairs(entities) do
        if entityComponentInstancesMatchComponentNames(componentInstances, componentNames) then
            table.insert(matching, entity)
        end
    end

    return matching
end

-- Returns the total number of component factories
--
-- return totalCount
function M.entityCount()
    local totalCount = 0

    for entity, componentInstances in pairs(entities) do
        if deadEntities[entity] == nil then
            totalCount = totalCount + 1
        end
    end

    return totalCount
end

------------------------------------------------------------------------------
-- Some functions for lazy registering/adding of all things ------------------
------------------------------------------------------------------------------
local function processLuaFilesInFolderReturningSubfolders(folder, processor)
    local subfolders = {}
    local requirePackage = string.gsub(folder, '/', '.')
    for i, filename in ipairs(love.filesystem.enumerate(folder)) do
        if string.match(filename, "\.lua$") ~= nil then
            local itemName = string.sub(filename, 1, #filename - 4) -- Eat the '.lua' extension
            local item = require(requirePackage..'.'..itemName)
            processor(itemName, item)
        elseif love.filesystem.isDirectory(folder..'/'..filename) then
            table.insert(subfolders, filename)
        end
    end
    return subfolders
end

-- Registers all lua files in the specified folder as component
-- factories.
--
-- This assumes that the component files are structured similar to this:
--     local M = {}
--     function M.factory()
--          return {
--             x = 0,
--             y = 0,
--         }
--     end
--     return M
--
-- The file may contain other code, variables and locals, but this
-- function requires that M.factory() is defined, as this is what
-- is registered as the component for that factory.
--
-- The component name is taken from the filename.
--
-- This does NOT walk down subfolders looking for components.
function M.registerAllComponentsIn(folder)
    M.print('LEF Registering all components in '..folder)
    processLuaFilesInFolderReturningSubfolders(folder,
        function(itemName, item)
            M.print('  Registering '..itemName)
            M.registerComponentFactory(itemName, item.factory)
        end)
end


-- Registers all lua files in the specified folder as systems under
-- the group '__no_group' and then uses the first level of subfolders
-- to add other systems that subfolder as members of that group. For
-- example:
--    systems/render/foo.lua
-- Calling lef.addAllSystemGroupsIn('systems') would result in the
-- system 'foo' being added in the group 'render'.
--
-- This assumes that the system files are structured similar to this:
--     local M = {}
--     M.components = {
--         'position',
--         'renderable',
--     }
--     M.priority = 1 -- Larger numbers get processed first
--     function M.processor(entities, lef)
--         for i, entity in ipairs(entities) do
--             local pos, img = lef.entityComponents(entity, 'position', 'renderable')
--             love.graphics.draw(img.image, pos.x, pos.y)
--         end
--     end
--     return M
--
-- The file may contain other code, variables and locals, but this
-- function requires that an M.processor(entities, lef) function and an array
-- M.components are defined. The components array is (generally) an array of strings
-- of component names and the M.processor function is what is called to
-- process all entities for that system when it is updates.
--
-- The system name is taken from the filename and the group from it's subfolder.
-- This function only looks one level deep for systems.
function M.addAllSystemGroupsIn(folder)
    M.print('LEF Registering all system groups in '..folder)
    local group = '__default'
    local subfolders = processLuaFilesInFolderReturningSubfolders(folder,
        function(itemName, item)
            item.priority = item.priority or 1
            M.print('  Registering '..itemName..' in group '..subfolder..' with priority '..item.priority)
            M.addSystem(group, itemName, item.priority or 1, item.processor, unpack(item.components))
        end)

    for i, subfolder in ipairs(subfolders) do
        processLuaFilesInFolderReturningSubfolders(folder..'/'..subfolder,
            function(itemName, item)
                item.priority = item.priority or 1
                M.print('  Registering '..itemName..' in group '..subfolder..' with priority '..item.priority)
                M.addSystem(subfolder, itemName, item.priority, item.processor, unpack(item.components))
            end)
    end
end

return M
