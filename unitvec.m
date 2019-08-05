% compute the unit vector correspoinding to a given vector
function v_out = unitvec( v_in )
	v_out = v_in / vecnorm(v_in);
