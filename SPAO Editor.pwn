


/*——————————————————————————————————————————————————————————————————————————————

						SetPlayerAttachedObject Creator
						-Crea y edita objetos en el jugador.
						-Guarda posiciónes en una archivo "scriptfiles/AttachmentsPositions.txt"
						
						Créditos:
						        	Felipe Blanco
——————————————————————————————————————————————————————————————————————————————*/

#include 	<a_samp>
#include 	<zcmd>

#define 	AttachSlot            	13500
#define 	AttachEliminar   		13501
#define 	AttachObj       		13502
#define		AttachParte   			13503
#define 	AttachGuardar 			13504
#define 	AttachGuardar2 			13505

#if !defined isnull
    #define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

#define FILTERSCRIPT


enum AttachInfo
{
	aModelo,
	aParte,
	Float:afOffsetX,
	Float:afOffsetY,
	Float:afOffsetZ,
	Float:afRotX,
	Float:afRotY,
	Float:afRotZ,
	Float:afScaleX,
	Float:afScaleY,
	Float:afScaleZ,
	aDescripcion[40],
};

new AI[MAX_PLAYER_ATTACHED_OBJECTS][AttachInfo];

public OnFilterScriptInit()
{
	new File:Archivo = fopen("AttachmentsPositions.txt", io_readwrite);
	fclose(Archivo);
	print("\n CARGANDO... SetPlayerAttachedObject Creator");
	print("BY: Feli Blanco\n");
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case AttachSlot:
        {
            if(response)
            {
                if(IsPlayerAttachedObjectSlotUsed(playerid, listitem))
                {
                    ShowPlayerDialog(playerid, AttachEliminar, DIALOG_STYLE_MSGBOX,"Ya hay algo en este slot", "¿Deseas eliminar este objeto o editarlo?", "Eliminar", "Editar");
                }
                else
                {
                    ShowPlayerDialog(playerid, AttachObj, DIALOG_STYLE_INPUT,"Elegir objeto", "Introduce el ID de un objeto","Seguir","Cancelar");
                }
                SetPVarInt(playerid, "AttachSlotE", listitem);
            }
        }
        case AttachEliminar:
        {
            if(response)
			{
			    new index = GetPVarInt(playerid, "AttachSlotE");
				RemovePlayerAttachedObject(playerid, GetPVarInt(playerid, "AttachSlotE"));
	    		AI[index][aModelo] = 0;
	    		AI[index][aParte] = 0;
	    		AI[index][afOffsetX] = 0.0;
				AI[index][afOffsetY] = 0.0;
				AI[index][afOffsetZ] = 0.0;
				AI[index][afRotX] = 0.0;
				AI[index][afRotY] = 0.0;
				AI[index][afRotZ] = 0.0;
				AI[index][afScaleX] = 0.0;
				AI[index][afScaleY] = 0.0;
				AI[index][afScaleZ] = 0.0;
				DeletePVar(playerid, "AttachSlotE");
			}
            else
			{
				EditAttachedObject(playerid, GetPVarInt(playerid, "AttachSlotE"));
            }
        }
        case AttachObj:
        {
            if(response)
            {
			    if(isnull(inputtext))
			    {
      				new string[300];
 					for(new slot = 0; slot <MAX_PLAYER_ATTACHED_OBJECTS; slot++)
  					{
   						if(IsPlayerAttachedObjectSlotUsed(playerid, slot))
   						{
   							format(string,sizeof(string),"%sSlot: %d [OCUPADO - %d]\n", string,slot,AI[slot][aModelo]);
						}
  						else
  						{
  							format(string,sizeof(string),"%sSlot: %d [DESOCUPADO]\n", string, slot);
						}
   					}
    				ShowPlayerDialog(playerid, AttachSlot, DIALOG_STYLE_LIST, "Elige un slot", string, "Siguiente", "Cancelar");
			    	return 1;
			    }
            	SetPVarInt(playerid, "AttachModeloE", strval(inputtext));
            	new string[400];
            	format(string,sizeof(string),"Lomo\nCabeza\nParte superior del brazo izquierdo\nParte superior del brazo derecho\nMano izquierda\nMano derecha");
                format(string,sizeof(string),"%s\nMuslo izquierdo\nMuslo derecho\nPie izquierdo\nPie derecho\nPantorrilla derecha\nPantorrilla izquierda",string);
                format(string,sizeof(string),"%s\nAntebrazo izquierdo\nAntebrazo derecho\nClavícula izquierda\nClavícula derecha\nCuello\nMandíbula",string);
                ShowPlayerDialog(playerid, AttachParte, DIALOG_STYLE_LIST,"Elige la parte", string, "Siguiente", "Cancelar");
            }
            else DeletePVar(playerid, "AttachSlotE");
        }
        case AttachParte:
        {
            if(response)
            {
                SetPlayerAttachedObject(playerid, GetPVarInt(playerid, "AttachSlotE"), GetPVarInt(playerid, "AttachModeloE"), listitem+1);
                EditAttachedObject(playerid, GetPVarInt(playerid, "AttachSlotE"));
            }
            else
            {
            	DeletePVar(playerid, "AttachSlotE");
            	DeletePVar(playerid, "AttachModeloE");
            }
        }
        case AttachGuardar:
        {
            if(response)
            {
                if(AI[listitem][aModelo] > 0)
                {
                    ShowPlayerDialog(playerid,AttachGuardar2,DIALOG_STYLE_INPUT,"Guardar","Elige una descripción breve","Guardar","Cancelar");
                    SetPVarInt(playerid,"GuardandoAttach",listitem);
                }
                else SendClientMessage(playerid,-1,"Ese slot está vacío.");
            }
        }
        case AttachGuardar2:
        {
            if(response)
            {
                if(strlen(inputtext) >  40) return SendClientMessage(playerid,-1,"Descripción muy larga.");
                new slot = GetPVarInt(playerid,"GuardandoAttach"),string[200+40];
                format(AI[slot][aDescripcion],40,"%s",inputtext);
                format(string,sizeof(string),"\r\nSetPlayerAttachedObject(playerid,%d,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f,%f); //%s",
				slot,
				AI[slot][aModelo],
				AI[slot][aParte],
				AI[slot][afOffsetX],
				AI[slot][afOffsetY],
				AI[slot][afOffsetZ],
				AI[slot][afRotX],
				AI[slot][afRotY],
				AI[slot][afRotZ],
				AI[slot][afScaleX],
				AI[slot][afScaleY],
				AI[slot][afScaleZ],
				inputtext);
				new File:Archivo = fopen("AttachmentsPositions.txt", io_append);
 	 			fwrite(Archivo, string);
	 			fclose(Archivo);
	 			SendClientMessage(playerid,-1,"Guardaste la posición correctamente.");
            }
        }
    }
    return 0;
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid,Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ,Float:fRotX, Float:fRotY, Float:fRotZ,Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
	new count=0,a;
	for(a = 0; a <MAX_PLAYER_ATTACHED_OBJECTS; a++)
	{
	    if(modelid == AI[a][aModelo]) count++;
	}
	if(count != 0 || modelid == GetPVarInt(playerid,"AttachModeloE"))
	{
	    AI[index][aModelo] = modelid;
	    AI[index][aParte] = boneid;
	    AI[index][afOffsetX] = fOffsetX;
		AI[index][afOffsetY] = fOffsetY;
		AI[index][afOffsetZ] = fOffsetZ;
		AI[index][afRotX] = fRotX;
		AI[index][afRotY] = fRotY;
		AI[index][afRotZ] = fRotZ;
		AI[index][afScaleX] = fScaleX;
		AI[index][afScaleY] = fScaleY;
		AI[index][afScaleZ] = fScaleZ;
 		DeletePVar(playerid, "AttachSlotE");
  		DeletePVar(playerid, "AttachModeloE");
  		SendClientMessage(playerid,-1,"<!> Usa /guardarattach para guardar las posiciones.");
	}
    return 1;
}

CMD:attached(playerid,params[])
{
	new string[300];
 	for(new slot = 0; slot <MAX_PLAYER_ATTACHED_OBJECTS; slot++)
  	{
   		if(IsPlayerAttachedObjectSlotUsed(playerid, slot))
   		{
   			format(string,sizeof(string),"%sSlot: %d [OCUPADO - %d]\n", string,slot,AI[slot][aModelo]);
		}
  		else
  		{
  			format(string,sizeof(string),"%sSlot: %d [DESOCUPADO]\n", string, slot);
		}
   	}
    ShowPlayerDialog(playerid, AttachSlot, DIALOG_STYLE_LIST, "Elige un slot", string, "Siguiente", "Cancelar");
	return 1;
}

CMD:saveattached(playerid,params[])
{
	new string[300];
 	for(new slot = 0; slot <MAX_PLAYER_ATTACHED_OBJECTS; slot++)
  	{
   		if(IsPlayerAttachedObjectSlotUsed(playerid, slot))
   		{
   			format(string,sizeof(string),"%sSlot: %d [OCUPADO - %d]\n", string,slot,AI[slot][aModelo]);
		}
  		else
  		{
  			format(string,sizeof(string),"%sSlot: %d [DESOCUPADO]\n", string, slot);
		}
   	}
   	ShowPlayerDialog(playerid,AttachGuardar,DIALOG_STYLE_LIST,"Guardar",string,"Siguiente","Cancelar");
	return 1;
}
