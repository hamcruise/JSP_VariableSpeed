int nj = ...;
int nm = ...;
range mchs = 1..nm;
range jobs = 1..nj;
int due[jobs] = ...;
int h=2* max(j in jobs) due[j];
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

int bigM= sum (o in Ops: o.v==1) o.pt;

tuple t_J {
  int j;   
  int pos; 
  int end;            
};
{t_J} Jobs={ <O.j, O.pos, O.end > | O in Ops};
execute  { cplex.tilim = 15; cplex.epagap=1e-12; }


dvar int+ X[Jobs];
dvar float+ cmax;
dvar boolean Y[Ops];
dvar boolean Z[Jobs][Jobs][mchs];
dexpr int tc=  sum(o in Ops) Y[o]*o.e*o.pt;	

minimize cmax*1000+tc;
subject to {   
  forall (j in Jobs) 
    sum(o in Ops: o.j==j.j && o.pos==j.pos) Y[o] == 1;
  forall (j in Jobs) forall(o in Ops: o.j==j.j && o.pos==j.pos) 
 	X[j] + Y[o]*o.pt  <= due[j.j] ;
  	
  forall (j1, j2 in Jobs, o in Ops:j1.j==j2.j && j1.pos+1==j2.pos && j1.j==o.j && j1.pos==o.pos )
      X[j1] + Y[o]* o.pt <= X[j2];
      
  forall (j1, j2 in Jobs, o1,o2 in Ops: j1!=j2 && j1.j==o1.j && j1.pos==o1.pos 
  				&& j2.j==o2.j && j2.pos==o2.pos && o1.m==o2.m) {
      X[j1] >= X[j2] + Y[o2] *o2.pt - bigM*Z[j1][j2][o1.m];
      X[j2] >= X[j1] + Y[o1] *o1.pt - bigM*(1-Z[j1][j2][o1.m]);
    }      
  forall (j in Jobs, o in Ops: o.j==j.j && o.pos==j.pos && o.end==1)
    cmax >= X[j] + Y[o]*o.pt;          
}     

execute {
writeln("makespan = ", cmax);
writeln("tc       = ", tc);

writeln("m"+"\t"+"j"+"\t"+"o"+"\t"+"pt" +"\t"+ "pw"+"\t"+ "v"+"\t"+"s"+"\t"+"e");
  for(var o in Ops)for(var j in Jobs)
    if (o.j==j.j && o.pos==j.pos && Y[o]==1)
	  writeln(o.m+"\t"+o.j+"\t"+o.pos+"\t"+o.pt+"\t"+o.e+"\t"+ o.v +"\t" +X[j]+"\t"+(X[j]+o.pt));
} 
    
