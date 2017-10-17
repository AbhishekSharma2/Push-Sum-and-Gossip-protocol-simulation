# Push-Sum-and-Gossip-protocol-simulation
Push-Sum and Gossip protocol simulation with Actor model on different topologies.
How to run the Code:

1. mix escript.build
2. escript ./project2 [ #nodes ] [topology] [algorithm]
3. eg .escript ./project2 50 full gossip

[#nodes] – needs to be numeric
[topology] – full, line, 2D, imp2D
[algorithm] – gossip, push-sum

The implemented topologies are:
 Full topology
 Line Topology
 2D Topology
 Imperfect 2D Topology
Protocols Implemented are:
 Push-Sum
 Gossip
For Gossip algorithm at command line either write “Gossip” or “gossip”. For other input it will run Push-
sum algorithm.
For topologies at command line write as follows:
For Full topology write -&gt;   “full”
For Line topology write -&gt; “line”
For 2D topology write -&gt; “2D”
For imperfect 2D topology write -&gt; “imp2D”
