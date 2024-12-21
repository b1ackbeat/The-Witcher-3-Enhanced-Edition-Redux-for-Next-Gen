/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


state MountTheVehicle in CR4Player extends Base
{
	protected var vehicle 		: CVehicleComponent;
	protected var mountType 		: EMountType;
	protected var vehicleSlot		: EVehicleSlot;
	
	private var camera : CCustomCamera;
	
	default mountType 	= MT_normal;


	
	// ImmersiveCam++
	private var setCameraHeading : bool;
	// ImmersiveCam--
	
	

	event OnEnterState( prevStateName : name )
	{
		// ImmersiveCam++
		var angDis : float;
		// ImmersiveCam--
		var exceptions : array< EInputActionBlock >;
		
		exceptions.PushBack( EIAB_Movement );
		exceptions.PushBack( EIAB_DismountVehicle );
		parent.BlockAllActions( 'MountVehicle', true, exceptions, true );
		
		// ImmersiveCam++
		if(Options().EnableImmersiveCam())
		{
			angDis = AngleDistance( theCamera.GetCameraHeading(), vehicle.GetHeading() );
			
			if( angDis > 90.0 || angDis < -90.0  )
				setCameraHeading = true;
			else
				setCameraHeading = false;
		}
		// ImmersiveCam--
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
		
		super.OnEnterState( prevStateName );
	}
	
	event OnLeaveState( nextStateName : name )
	{ 
		super.OnLeaveState( nextStateName );
		
		vehicle = NULL;
		parent.RemoveTimer( 'UpdateTraverser' );
		parent.BlockAllActions( 'MountVehicle', false );
	}
	
	
	
	
	
	final function SetupState( v : CVehicleComponent, inMountType : EMountType, inVehicleSlot : EVehicleSlot )
	{
		LogAssert( !vehicle, "MountTheVehicle::SetupState, 'vehicle' is already set" );
		
		vehicle 	= v;
		mountType 	= inMountType;
		vehicleSlot	= inVehicleSlot;
	}
	
	cleanup function MountCleanup()
	{
	
	}
	
	protected function OnMountingFailed()
	{	
		vehicle.OnDismountStarted( parent );
		vehicle.OnDismountFinished( parent, thePlayer.GetRiderData().sharedParams.vehicleSlot );
		
		parent.ActionCancelAll();
		parent.EnableCharacterCollisions( true );
		parent.RegisterCollisionEventsListener();
	}
	
	function ContinuedState()
	{
		parent.PopState( true );
	}

	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		var vehicleHeading : float;
		
		
		if(!Options().EnableImmersiveCam())
		{
		if( (W3HorseComponent)vehicle && thePlayer.GetHorseCamera())
		{
			moveData.pivotDistanceController.SetDesiredDistance( 1.5f );
			DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 0.8f, -0.7f, 0.1f ), 1.0f, dt );
			return true;
		}
		

		vehicleHeading = vehicle.GetHeading();
		moveData.pivotRotationController.SetDesiredHeading( vehicleHeading, 0.25 );
		
		return true;
		}
		else
		{
			vehicleHeading = vehicle.GetHeading();
			if( setCameraHeading )
			{
				moveData.pivotRotationController.SetDesiredHeading( vehicleHeading, 0.25 );
				moveData.pivotRotationController.SetDesiredPitch( 5.0f );
			}
		}
	}
}
