int nj = ...;
int nm = ...;
range mchs = 1..nm;
range jobs = 1..nj;
int due[jobs] = ...;
int h=max(j in jobs) due[j];
tuple t_Op {
  int j;   
  int pos; 
  int m;  
  int pt;
  int end; 
  int prevMch;
  int e;     
  int v;               
};
{t_Op} Ops=...;

int nbProcess= max (o in Ops) o.pos;

tuple t_J {
  int j;   
  int pos; 
  int end;            
};
{t_J} Jobs={ <O.j,  O.pos, O.end > | O in Ops};
range Pos = 1..nbProcess*nj; 
range Pos2 = 1..nbProcess*nj-1; 

execute  { cplex.tilim = 60; cplex.epagap=1e-12; }

dvar boolean X[Ops];
dvar boolean Y[Ops][Pos];
dvar boolean Z[mchs][Pos];
dvar float+ B[Jobs];
dvar float+ E[Jobs];
dvar float+ S[mchs][Pos];
dvar float+ F[mchs][Pos];
dvar int+ cmax;
dexpr int tc=  sum(o in Ops, t in Pos) Y[o][t]*o.e*o.pt;	

minimize cmax*1000+tc;
subject to {
  
  forall (j in Jobs)  sum(o in Ops: o.j==j.j && o.pos==j.pos) X[o]==1;
  
  forall (o in Ops) sum(t in Pos) Y[o][t]==X[o];

  forall (m in mchs,t in Pos) sum(o in Ops: o.m==m) Y[o][t] <= 1;
  
  forall (m in mchs,t in Pos2) 
    sum(o in Ops: o.m==m) Y[o][t] >= sum(o in Ops: o.m==m) Y[o][t+1];

  forall (m in mchs,t in Pos)	
    F[m][t]==S[m][t] + sum(o in Ops: o.m==m) o.pt*Y[o][t];

  forall (m in mchs,t in Pos2) {	
	S[m][t+1] - F[m][t] >= - h*(1-Z[m][t]);
	S[m][t+1] - F[m][t] <= h*(Z[m][t]);
	F[m][t] <=S[m][t+1];
	}
  forall (m in mchs, j in Jobs,o in Ops, t in Pos: o.m==m && o.j==j.j && o.pos==j.pos) {
 	S[m][t] + h*(1-Y[o][t]) >= B[j];
  	S[m][t] <= B[j] + h*(1-Y[o][t]);
	}	
  forall (j in Jobs) 
         E[j]==B[j] + sum(o in Ops: o.j==j.j && o.pos==j.pos) o.pt*X[o];
  forall (j1,j2 in Jobs: j1.j==j2.j && j1.pos+1==j2.pos) E[j1] <=B[j2];
  forall (j in Jobs) E[j]  <= due[j.j] ;
  forall (j in Jobs) cmax >= E[j];      
}     

execute {
writeln("makespan = ", cmax);
writeln("tc       = ", tc);
writeln("m"+"\t"+"j"+"\t"+"o"+"\t"+"pt" +"\t"+ "pw"+"\t"+ "v"+"\t"+"s"+"\t"+"e");
  for(var o in Ops) for(var j in Jobs) for(var t in Pos)
    if (o.j==j.j && o.pos==j.pos && Y[o][t] == 1)
	  writeln(o.m+"\t"+o.j+"\t"+o.pos+"\t"+o.pt+"\t"+o.e+"\t"+ o.v +"\t" +B[j]+"\t"+E[j]);
} 
    