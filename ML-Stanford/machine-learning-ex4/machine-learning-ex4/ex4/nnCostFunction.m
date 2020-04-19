function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


% ----------- PART I : REGULARIZED COST FUNCTION ------------
% append bias term
X = [ones(m, 1) X];
% calculate activion of input layer
z2 = Theta1 * X';
a2 = sigmoid(z2);
% append bias term
m_a2 = size(a2, 2);
a2 = [ones(1, m_a2);a2];
% calculate activion of hidden layer
z3 = Theta2 * a2;
a3 = sigmoid(z3);

% let y and hx be in the same form for convinience
hx = a3';
unrolled_y = zeros(size(hx));
% "unroll" the given y vector
for i = 1:size(unrolled_y,1)
    oneValueIndex = mod(y(i),10); 
    if(oneValueIndex == 0)
        unrolled_y(i, 10) = 1;
    else        
        unrolled_y(i, oneValueIndex) = 1;
    end;
end;
%calculate cost
J = -unrolled_y .* log(hx)-(1-unrolled_y).*log(1-hx);
J = sum(J(:)) / m;

% regularization part
t1 = Theta1(:,2:end).^2;
t1 = sum(t1(:));

t2 = Theta2(:,2:end).^2;
t2 = sum(t2(:));

regPart = (t1+t2) * (lambda/(2*m));

J = J + regPart;

% ----------- PART II : REGULARIZED GRADIENTS ------------
% error in the output layer
errorOut = hx - unrolled_y;

% error in hidden layer
errorHidden = errorOut * Theta2;
errorHidden = errorHidden(:, 2:end);
errorHidden = errorHidden .* sigmoidGradient(z2');

%calculate the accumulators
%exclude bias term
a1 = X;
Theta1_grad = (errorHidden' * a1) /m;
Theta2_grad = (errorOut' * a2') /m;

% regularization part
coefficent = lambda / m;

Theta1_grad(:, 2:end) = Theta1_grad(:, 2:end) + coefficent * Theta1(:, 2:end); 
Theta2_grad(:, 2:end) = Theta2_grad(:, 2:end) + coefficent * Theta2(:, 2:end); 

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end