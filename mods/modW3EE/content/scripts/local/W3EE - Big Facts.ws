function BigFactSet( id : string, value : int, optional validFor : int )
{ 
	var part0 : int;
	var part1 : int;
	
	if( value < 0 )
		part0 = ~(~value / 0x10000);
	else
		part0 = value / 0x10000;
		
	part1 = value & 0xffff;
	FactsSet(id + "_p0", part0, validFor);
	FactsSet(id + "_p1", part1, validFor);
}

function BigFactGet( id : string ) : int
{
	var part0 : int;
	var part1 : int;
	
	part0 = FactsQuerySum(id + "_p0");
	part1 = FactsQuerySum(id + "_p1");
	
	if( part1 < 0 )
	{
		part1 = part1 ^ 0xffff;
		part1 = part1 + 1;
		part1 = part1 * -1;
	}
	return part0 * 0x10000 | part1;
}


function BigFactExists( id : string ) : bool
{
	return FactsDoesExist(id + "_p0") && FactsDoesExist(id + "_p1");
}

function BigFactRemove( id : string )
{
	FactsRemove(id + "_p0");
	FactsRemove(id + "_p1");
}


exec function fact(id : string)
{
	theGame.GetGuiManager().ShowNotification(FactsQuerySum(id));
}

exec function factAdd(id : string, val : int)
{
	FactsAdd(id, val);
}

exec function factTest()
{
	var i : int;
	for(i = -2147483640; i < 2147471640; i+=1000)
	{
		BigFactSet("was", i);
		if (BigFactGet("was") != i)
		{
			theGame.GetGuiManager().ShowNotification(i);
		}
	}
}

exec function tele()
{
	GetWitcherPlayer().Teleport((Vector)(0,0,0));
}

exec function pos()
{
	var p : Vector;
	p = GetWitcherPlayer().GetPositionOrMoveDestination();
	theGame.GetGuiManager().ShowNotification(p.X + ","+ p.Y +","+p.Z);
}