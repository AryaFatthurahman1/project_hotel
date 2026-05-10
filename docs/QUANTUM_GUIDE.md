# QuantumForge - Quantum Programming Guide

## Table of Contents

1. [Getting Started](#getting-started)
2. [Quantum Circuit Design](#quantum-circuit-design)
3. [Algorithm Implementations](#algorithm-implementations)
4. [Optimization Problems](#optimization-problems)
5. [Error Mitigation](#error-mitigation)
6. [Best Practices](#best-practices)

---

## Getting Started

### Installation

```bash
# Install Qiskit
pip install qiskit qiskit-machine-learning qiskit-optimization

# Install Cirq
pip install cirq cirq-google

# Install PennyLane
pip install pennylane

# Install QuantumForge SDK
pip install quantum-forge-sdk
```

### Basic Circuit

```python
from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
from quantum_forge import QuantumClient

# Initialize client
client = QuantumClient(api_key="your-api-key")

# Create a simple Bell state
qc = QuantumCircuit(2, 2)
qc.h(0)               # Hadamard on qubit 0
qc.cx(0, 1)           # CNOT: control=0, target=1
qc.measure([0, 1], [0, 1])

# Execute on quantum provider
job = client.execute(
    circuit=qc,
    provider="ibm",
    shots=1000
)

# Get results
result = job.result()
print(result.get_counts())
# Output: {'00': 500, '11': 500}
```

---

## Quantum Circuit Design

### Qubit Allocation

```python
from qiskit import QuantumCircuit

# Method 1: Direct specification
qc = QuantumCircuit(5)  # 5 qubits

# Method 2: Named qubits
qr = QuantumRegister(5, 'q')
cr = ClassicalRegister(5, 'c')
qc = QuantumCircuit(qr, cr)

# Method 3: Multiple registers
qr_data = QuantumRegister(3, 'data')
qr_ancilla = QuantumRegister(2, 'ancilla')
cr = ClassicalRegister(3, 'result')
qc = QuantumCircuit(qr_data, qr_ancilla, cr)
```

### Common Gates

```python
from qiskit import QuantumCircuit
import numpy as np

qc = QuantumCircuit(3)

# Single-qubit gates
qc.x(0)           # Pauli-X (NOT)
qc.y(0)           # Pauli-Y
qc.z(0)           # Pauli-Z
qc.h(0)           # Hadamard
qc.s(0)           # Phase gate (S = √Z)
qc.t(0)           # T gate (T = √S)
qc.rx(np.pi/4, 0) # RX rotation
qc.ry(np.pi/2, 0) # RY rotation
qc.rz(np.pi/3, 0) # RZ rotation

# Multi-qubit gates
qc.cx(0, 1)       # CNOT (controlled-X)
qc.cy(0, 1)       # CNOT (controlled-Y)
qc.cz(0, 1)       # Controlled-Z
qc.swap(0, 1)     # SWAP
qc.toffoli(0, 1, 2)  # Toffoli (Deutsch gate)

# Measurement
qc.measure_all()
```

### Circuit Composition

```python
from qiskit import QuantumCircuit

# Create subcircuits
subcircuit1 = QuantumCircuit(2)
subcircuit1.h(0)
subcircuit1.cx(0, 1)

subcircuit2 = QuantumCircuit(2)
subcircuit2.rz(np.pi/4, 0)
subcircuit2.rz(np.pi/4, 1)

# Compose circuits
main_circuit = QuantumCircuit(4)
main_circuit.append(subcircuit1, [0, 1])
main_circuit.append(subcircuit2, [2, 3])

# Alternative: circuit composition
main_circuit = subcircuit1.compose(subcircuit2)
```

---

## Algorithm Implementations

### Deutsch-Jozsa Algorithm

```python
from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister

def deutsch_jozsa_algorithm(n: int, is_constant: bool) -> QuantumCircuit:
    """
    Deutsch-Jozsa algorithm for determining if function is constant or balanced
    
    Args:
        n: Number of input qubits
        is_constant: If True, implement constant function
    
    Returns:
        Quantum circuit implementing the algorithm
    """
    qr = QuantumRegister(n + 1, 'q')
    cr = ClassicalRegister(n, 'c')
    qc = QuantumCircuit(qr, cr)
    
    # Initialization
    qc.x(qr[n])
    for i in range(n + 1):
        qc.h(qr[i])
    qc.barrier()
    
    # Oracle
    if is_constant:
        # Constant function: identity or global phase
        if np.random.rand() > 0.5:
            qc.z(qr[n])
    else:
        # Balanced function: flip based on one input
        qc.cx(qr[0], qr[n])
    
    qc.barrier()
    
    # Measurement basis
    for i in range(n):
        qc.h(qr[i])
    qc.barrier()
    
    # Measurement
    qc.measure(qr[:n], cr)
    
    return qc

# Use it
circuit = deutsch_jozsa_algorithm(n=3, is_constant=True)
```

### Grover's Algorithm

```python
from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
from qiskit.circuit.library import GroverOperator, MCMT, ZGate
import numpy as np

def grovers_algorithm(num_qubits: int, marked_state: int) -> QuantumCircuit:
    """
    Grover's algorithm for quantum search
    
    Args:
        num_qubits: Number of qubits
        marked_state: The state we're searching for
    
    Returns:
        Quantum circuit implementing Grover's algorithm
    """
    qr = QuantumRegister(num_qubits, 'q')
    cr = ClassicalRegister(num_qubits, 'c')
    qc = QuantumCircuit(qr, cr)
    
    # Create superposition
    for i in range(num_qubits):
        qc.h(qr[i])
    qc.barrier()
    
    # Calculate optimal iterations
    iterations = int(np.pi / 4 * np.sqrt(2**num_qubits))
    
    for _ in range(iterations):
        # Oracle: mark the target state
        target_bits = format(marked_state, f'0{num_qubits}b')
        for i, bit in enumerate(target_bits):
            if bit == '0':
                qc.x(qr[i])
        
        # Multi-controlled Z gate
        if num_qubits == 1:
            qc.z(qr[0])
        elif num_qubits == 2:
            qc.cz(qr[0], qr[1])
        else:
            qc.h(qr[-1])
            qc.mcx(qr[:-1], qr[-1])
            qc.h(qr[-1])
        
        for i, bit in enumerate(target_bits):
            if bit == '0':
                qc.x(qr[i])
        
        qc.barrier()
        
        # Diffuser (inversion about average)
        for i in range(num_qubits):
            qc.h(qr[i])
        for i in range(num_qubits):
            qc.x(qr[i])
        
        if num_qubits == 1:
            qc.z(qr[0])
        elif num_qubits == 2:
            qc.cz(qr[0], qr[1])
        else:
            qc.h(qr[-1])
            qc.mcx(qr[:-1], qr[-1])
            qc.h(qr[-1])
        
        for i in range(num_qubits):
            qc.x(qr[i])
        for i in range(num_qubits):
            qc.h(qr[i])
        
        qc.barrier()
    
    # Measurement
    qc.measure(qr, cr)
    
    return qc

# Use it
circuit = grovers_algorithm(num_qubits=4, marked_state=7)
```

### Variational Quantum Eigensolver (VQE)

```python
from qiskit_machine_learning.neural_networks import CircuitQNN
from qiskit.circuit import ParameterVector, QuantumCircuit
from qiskit.primitives import Estimator
from scipy.optimize import minimize
import numpy as np

def create_vqe_ansatz(num_qubits: int, depth: int) -> QuantumCircuit:
    """Create a parameterized ansatz circuit"""
    theta = ParameterVector('θ', num_qubits * depth)
    qc = QuantumCircuit(num_qubits)
    
    idx = 0
    for _ in range(depth):
        # Single qubit rotations
        for i in range(num_qubits):
            qc.ry(theta[idx], i)
            idx += 1
        
        # Entangling layer
        for i in range(num_qubits - 1):
            qc.cx(i, i + 1)
    
    return qc

def vqe_optimize(hamiltonian_coeffs: dict, num_qubits: int, depth: int):
    """
    Optimize parameterized circuit to find ground state
    
    Args:
        hamiltonian_coeffs: Dict of Pauli term coefficients
        num_qubits: Number of qubits
        depth: Circuit depth
    """
    ansatz = create_vqe_ansatz(num_qubits, depth)
    
    def objective_function(params):
        # Bind parameters and evaluate
        bound_circuit = ansatz.bind_parameters(params)
        # Execute and compute expectation value
        # (implementation depends on backend)
        return expectation_value
    
    # Optimize
    initial_params = np.random.rand(num_qubits * depth) * 2 * np.pi
    result = minimize(objective_function, initial_params, method='COBYLA')
    
    return result

# Use it
vqe_result = vqe_optimize(
    hamiltonian_coeffs={'ZZ': 0.5, 'X': 0.3},
    num_qubits=4,
    depth=3
)
```

---

## Optimization Problems

### Quadratic Unconstrained Binary Optimization (QUBO)

```python
from qiskit.optimization import QuadraticProgram
from qiskit.algorithms import QAOA
from qiskit.primitives import Sampler

def solve_maxcut(graph_edges: list, num_vertices: int):
    """
    Solve MAX-CUT problem using QAOA
    
    Args:
        graph_edges: List of edges as tuples (i, j)
        num_vertices: Number of vertices in graph
    """
    # Define QUBO
    qp = QuadraticProgram('maxcut')
    
    # Add binary variables
    for i in range(num_vertices):
        qp.binary_var(name=f'x{i}')
    
    # Objective: maximize edges between different partitions
    objective = {}
    for i, j in graph_edges:
        # Encourage x_i != x_j
        key = (i, j) if i < j else (j, i)
        objective[key] = objective.get(key, 0) + 1
    
    qp.maximize(objective)
    
    # Solve with QAOA
    qaoa = QAOA(sampler=Sampler(), reps=3)
    result = qaoa.compute_minimum_eigenvalue(qp.operator)
    
    return result

# Use it
edges = [(0,1), (1,2), (2,3), (3,0), (0,2)]
result = solve_maxcut(edges, num_vertices=4)
```

### Portfolio Optimization

```python
from qiskit.optimization import QuadraticProgram
from qiskit.optimization.applications import PortfolioOptimization
from qiskit.algorithms import VQE

def optimize_portfolio(expected_returns: list, covariances: list, risk_factor: float):
    """
    Solve portfolio optimization using quantum algorithm
    
    Args:
        expected_returns: Array of expected returns
        covariances: Covariance matrix
        risk_factor: Risk aversion parameter
    """
    # Create portfolio optimization problem
    portfolio = PortfolioOptimization(
        expected_returns=expected_returns,
        covariances=covariances,
        risk_factor=risk_factor,
        budget=len(expected_returns) // 2,  # Select half the assets
        bounds=[(0, 1) for _ in expected_returns]
    )
    
    qp = portfolio.to_quadratic_program()
    
    # Solve with VQE
    vqe = VQE(ansatz=..., optimizer=..., estimator=...)
    result = vqe.compute_minimum_eigenvalue(qp.operator)
    
    return result
```

---

## Error Mitigation

### Zero-Noise Extrapolation

```python
from qiskit_aer import AerSimulator
from qiskit.primitives import Estimator
import numpy as np

def zero_noise_extrapolation(circuit, num_noise_levels: int = 3):
    """
    Mitigate errors using zero-noise extrapolation
    
    Args:
        circuit: Quantum circuit
        num_noise_levels: Number of noise levels to evaluate
    """
    # Create circuits with different noise levels
    scaled_circuits = []
    noise_factors = [1.0, 1.5, 2.0][:num_noise_levels]
    
    for factor in noise_factors:
        # Insert identity gates to scale noise
        scaled_qc = circuit.copy()
        # Scaling implementation
        scaled_circuits.append(scaled_qc)
    
    # Measure expectation values at different noise levels
    expectations = []
    for scaled_circuit in scaled_circuits:
        # Execute and get expectation value
        exp_value = execute_and_measure(scaled_circuit)
        expectations.append(exp_value)
    
    # Extrapolate to zero noise
    # Fit: E(noise) = a + b*noise
    noise_factors = np.array(noise_factors)
    coefficients = np.polyfit(noise_factors, expectations, 1)
    zero_noise_expectation = coefficients[1]  # a term
    
    return zero_noise_expectation
```

### Symmetric Error Mitigation

```python
def symmetry_error_mitigation(circuit, observable):
    """
    Apply symmetry-based error mitigation
    
    Args:
        circuit: Quantum circuit
        observable: Observable to measure
    """
    # Measure expectation value normally
    normal_result = measure_observable(circuit, observable)
    
    # Apply twirling: random Pauli gates before measurement
    num_twirls = 10
    twirled_results = []
    
    for _ in range(num_twirls):
        # Add random Pauli gates before measurement
        twirled_circuit = circuit.copy()
        for qubit in range(circuit.num_qubits):
            pauli_choice = np.random.choice(['I', 'X', 'Y', 'Z'])
            if pauli_choice == 'X':
                twirled_circuit.x(qubit)
            elif pauli_choice == 'Y':
                twirled_circuit.y(qubit)
            elif pauli_choice == 'Z':
                twirled_circuit.z(qubit)
        
        result = measure_observable(twirled_circuit, observable)
        twirled_results.append(result)
    
    # Average the twirled results
    mitigated_result = np.mean(twirled_results)
    
    return mitigated_result
```

---

## Best Practices

### 1. Circuit Optimization

```python
from qiskit import transpile
from qiskit_aer import AerSimulator

# Optimize circuit for target backend
backend = AerSimulator()
optimized_circuit = transpile(
    circuit,
    backend=backend,
    optimization_level=3,  # 0=None, 1=Light, 2=Medium, 3=Heavy
    seed_transpiler=42
)

print(f"Original depth: {circuit.depth()}")
print(f"Optimized depth: {optimized_circuit.depth()}")
```

### 2. Parameter Tuning

```python
# Use consistent seeding for reproducibility
import numpy as np
np.random.seed(42)

# Adaptive learning rates for optimization
learning_rate = 0.01
decay_rate = 0.95
for iteration in range(100):
    # Update parameters
    lr = learning_rate * (decay_rate ** iteration)
    # ...
```

### 3. Resource Management

```python
# Monitor circuit resources
def analyze_circuit(qc):
    return {
        'num_qubits': qc.num_qubits,
        'num_gates': len(qc.data),
        'depth': qc.depth(),
        'width': qc.width(),
        '2qubit_gates': sum(1 for gate in qc.data if len(gate[1]) == 2),
        'estimated_error': 0.01 * len(qc.data)  # Rough estimate
    }

# Keep circuits manageable
if analyze_circuit(qc)['num_qubits'] > 20:
    print("Warning: Large circuit may exceed available resources")
```

### 4. Error Handling

```python
try:
    job = client.execute(circuit, provider="ibm", shots=1000)
    result = job.result(timeout=600)
except Exception as e:
    print(f"Execution failed: {e}")
    # Fallback to classical simulation
    from qiskit_aer import AerSimulator
    simulator = AerSimulator()
    job = simulator.run(circuit, shots=1000)
    result = job.result()
```

---

## Advanced Topics

### Quantum Machine Learning

```python
# See PennyLane documentation for quantum ML with automatic differentiation
import pennylane as qml

dev = qml.device("default.qubit", wires=4)

@qml.qnode(dev)
def quantum_circuit(inputs, weights):
    # Embed inputs
    for i, x in enumerate(inputs):
        qml.RX(x, wires=i)
    
    # Parametrized layers
    for w in weights:
        qml.RY(w, wires=0)
        qml.CNOT(wires=[0, 1])
    
    return qml.expval(qml.PauliZ(0))

# Training loop
weights = np.random.rand(4)
opt = qml.GradientDescentOptimizer(stepsize=0.1)

for step in range(100):
    weights = opt.step(lambda w: quantum_circuit([0.1, 0.2], w), weights)
```

---

For more examples and documentation, visit:
- [Qiskit Documentation](https://qiskit.org/documentation)
- [PennyLane Tutorials](https://pennylane.ai/qml)
- [Cirq Tutorials](https://quantumai.google/cirq/tutorials)

