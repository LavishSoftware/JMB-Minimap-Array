objectdef minimaparraySession
{
    variable uint RefreshedSlots

    method Initialize()
    {
        LavishScript:RegisterEvent[OnFrame]
        Event[OnFrame]:AttachAtom[This:OnFrame]

        LGUI2:LoadPackageFile[MinimapArray.Session.lgui2Package.json]

        This:SetSourceEnabled[1]
    }

    method Shutdown()
    {
        LGUI2:UnloadPackageFile[MinimapArray.Session.lgui2Package.json]
        
        ; explicitly destroy dynamically loaded elements
        This:SetSourceEnabled[0]
    }


    method OnFrame()
    {
        if ${JMB.Slots.Used}!=${RefreshedSlots}
            This:RefreshSlots
    }

     method RefreshSlots()
     {
         variable uint numSlots=${JMB.Slots.Used}
         variable uint Slot

         RefreshedSlots:Set[${numSlots}]

         LGUI2.Element[minimaparray.viewerpanel]:ClearChildren
         
         for ( Slot:Set[1] ; ${Slot}<=${numSlots} ; Slot:Inc )
         {
            This:AddSlot[${Slot}]
         }
     }

    method AddSlot(uint Slot)
    {
        if ${Slot}==${JMB.Slot}
            return

        variable jsonvalue jo

        variable string focusCommand="MinimapArraySession:Focus[${Slot}]"
        jo:SetValue["$$>
        {
            "type":"button",
            "borderThickness":0,
            "content":{
                "jsonTemplate": "minimaparray.viewer",
                "feedName": "minimap${Slot}"
            },
            "eventHandlers":{
                "onPress":{
                    "type":"code",
                    "code":${focusCommand.AsJSON~}
                }
            }
        }
        <$$"]

        LGUI2.Element[minimaparray.viewerpanel]:AddChild["${jo.AsJSON~}"]
    }

    method Focus(uint Slot)
    {
        uplink focus "jmb${Slot}"
        relay "jmb${Slot}" "Event[OnHotkeyFocused]:Execute"
    }

    method SetSourceEnabled(bool newValue)
    {
        if ${newValue}
        {
            LGUI2.Element[minimaparray.source]:Destroy

            variable jsonvalue jo
            jo:SetValue["${LGUI2.Template[minimaparray.source].AsJSON~}"]

            jo:Set["feedName","\"minimap${JMB.Slot}\""]

            LGUI2:LoadJSON["${jo.AsJSON~}"]
        }
        else
        {
            LGUI2.Element[minimaparray.source]:Destroy
        }
    }
}

variable(global) minimaparraySession MinimapArraySession

function main()
{
    while 1
        waitframe
}