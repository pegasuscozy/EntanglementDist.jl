# Defines some commonly used states in quantum information

export bell, wernerState, rState, rStateQutrit, rStatePhase, rStateCorrPhase, rStateCorrPhaseCopies;

""" `bell`

The Bell states (as vectors), bell[j,1:4] gives the j-th bell state.
"""
bell = zeros(4,4);
bell[1,1:4] = maxEntVec(2);
bell[2,1:4] = (kron(eVec(2,1),eVec(2,1)) -  kron(eVec(2,2),eVec(2,2)))/sqrt(2);
bell[3,1:4] = (kron(eVec(2,1),eVec(2,2)) +  kron(eVec(2,2),eVec(2,1)))/sqrt(2);
bell[4,1:4] = (kron(eVec(2,1),eVec(2,2)) -  kron(eVec(2,2),eVec(2,1)))/sqrt(2);

""" `epr` and `singlet`

Two of these have special names: we will use epr for the EPR pair, and singlet for the singlet.
"""
epr = bell[1,1:4];
singlet = bell[4,1:4];

""" `bellS`

An array of density matrices corresponding to the 4 Bell states.
"""
bS1 = epr*epr';
bS2 = bell[2,1:4]* bell[2,1:4]';
bS3 = bell[3,1:4]* bell[3,1:4]';
bS4 = bell[4,1:4]*bell[4,1:4]';
bellS = [bS1; bS2; bS3; bS4];

""" `PS`
Projector onto the symmetric subspace of 2 qubits.
"""
PS = bS1 + bS2 + bS3;

""" `PA`
Projector onto the antisymmetric subspace of 2 qubits.
"""
PA = bS4;

""" `rho = rState(p)`

Returns a state that is an a mixture between the EPR pair (with probability *p*), and the state |01><01|.
"""

function rState(p)

	@assert 0 <= p "Probilities must be positive."
	@assert p <= 1 "Probabilities cannot exceed 1."

	# Generate the maximally entangled state
	epr = maxEnt(2);

	# Generate |01>
	e0 = [1 0];
	e1 = [0 1];
	v11 = kron(e0,e1);

	# Produce the desired mixture
	out = p * epr + (1-p) * v11'*v11;
	return out;
end

""" `rho = rStateQutrit(p)`

Returns a state that is a mixture between a 3 dimensional maximally entangled state (with probability *p*) and the state |00><00|
"""

function rStateQutrit(p::Number)

	@assert 0 <= p "Probilities must be positive."
	@assert p <= 1 "Probabilities cannot exceed 1."

	# Maximally entangled state 
	epr = maxEnt(3);

	# Generate |00>
	e0 = [1 0 0];
	e1 = [0 0 1];
	v00 = kron(e0,e1);

	# Produce the desired mixture
	out = p * epr + (1-p) * v00'*v00;

  	return out;
end

#
# Outputs a ronald state of the form p EPR + (1-p) |0><0|
#
# Inputs: p

""" `rho = rStatePhase(p, phi)` or `rho = rStatePhase(p)`

Returns a mixture between a state proportional to |01> + e^(i *phi*) |10> (with probability *p*) and the state |00><00|. No value for *phi* defaults to *phi*=0.

"""

function rStatePhase(p::Number, phi::Number = 0.0)

	@assert 0 <= p "Probilities must be positive."
	@assert p <= 1 "Probabilities cannot exceed 1."

	# Produce the state |00> + e^(i phi) |11>
	e0 = eVec(2, 1);
	e1 = eVec(2, 2);
	vec = (kron(e0, e1) + e^(im*phi) * kron(e1,e0))/sqrt(2);

	if phi == 0 || phi == pi
		vec = real(vec);
	end

	# Produce a state orthogonal to the one above
	v00 = kron(e0,e0);

	# Construct the desire mixture
	out = p * vec*vec' + (1-p) * v00*v00';

  	return out
end

""" `rho = rStateCorrPhase(p)`

Returns a state of the form integral phi r(p,phi) tensor r(p,phi), where 
r(p,phi) = rStatePhase(p,phi).
"""
function rStateCorrPhase(p::Number)

	@assert 0 <= p "Probilities must be positive."
	@assert p <= 1 "Probabilities cannot exceed 1."

	integrand(phi) = ( 1/(2*pi) ) * kron(rStatePhase(p, phi), rStatePhase(p, phi));

	eps = 10.0^(-4)
	out = real( quadgk( integrand, 0, 2 * pi; reltol=sqrt(eps), abstol=0, maxevals=10^7, order=7, norm=vecnorm)[1])
  	return out
end


""" `rho = rStateCorrPhase(p)`

Returns a state of the form integral phi r(p,phi)^(tensor n) , where 
r(p,phi) = rStatePhase(p,phi) and n is the number of desired copies.
"""
function rStateCorrPhaseCopies(p::Number, n::Int)

	@assert 0 <= p "Probilities must be positive."
	@assert p <= 1 "Probabilities cannot exceed 1."
	@assert n > 1 "Number of copies must be at least 1."

	integrand(phi) = ( 1/(2*pi) ) * copies(rStatePhase(p, phi), n);

	eps = 10.0^(-4)
	out = real( quadgk( integrand, 0, 2 * pi; reltol=sqrt(eps), abstol=0, maxevals=10^7, order=7, norm=vecnorm)[1])
  	return out
end

""" `rho = wernerState(p)` or `rho = wernerState(p,d)`

Returns a werner state, i.e., a mixture of a maximally entangled pair (with probability *p*) and the maximally mixed state in local dimension *d*. If no argument *d* is given the default is *d*=2, that is, we take the mixture of the EPR pair with the maximally entangled state.
"""

function wernerState(p::Number; d::Int = 2)

	@assert 0 <= p "Probilities must be positive."
	@assert p <= 1 "Probabilities cannot exceed 1."

        epr = maxEnt(d);
	out = p * epr*epr' + (1-p) * eye(d^2)/d^2;
		
	return out;
end


