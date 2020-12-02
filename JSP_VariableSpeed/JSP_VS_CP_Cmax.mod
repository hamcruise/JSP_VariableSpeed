using CP;
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

tuple t_J {
  int j;   
  int pos; 
  int end;            
};
{t_J} Jobs={ <O.j, O.pos, O.end > | O in Ops};

dvar interval itvJ[j in Jobs] in 0..h;
dvar interval itvO[o in Ops] optional in 0..h size o.pt ;
dvar sequence seqMchs[m in mchs] in all(o in Ops : o.m == m) itvO[o];

dexpr int cmax=  max(j in Jobs: j.end==1) endOf(itvJ[j]);		  
dexpr int tc=  sum(o in Ops) presenceOf(itvO[o])*o.e*o.pt;		  
execute {
  cp.param.TimeLimit = 5;
  cp.param.LogVerbosity=21;  
  cp.param.TemporalRelaxation = "On";
  cp.param.NoOverlapInferenceLevel = "Extended"    
} 			  	

minimize cmax;
subject to {
  forall (j in Jobs) {
	alternative(itvJ[j], all(o in Ops: j.j==o.j && j.pos==o.pos) itvO[o]);
  	endOf(itvJ[j]) <= due[j.j];
  }	  
  forall (m in mchs)
    noOverlap(seqMchs[m]);
  forall (j1, j2 in Jobs:j1.j==j2.j && j1.pos+1==j2.pos)
    endBeforeStart(itvJ[j1], itvJ[j2]);
}

execute {
writeln("makespan = ", cmax);
writeln("tc       = ", tc);
writeln("m"+"\t"+"j"+"\t"+"o" +"\t"+ "pt" +"\t"+ "pw"+"\t"+ "v"+"\t"+ "s"+"\t"+ "e");
for(var o in Ops) if(itvO[o].present)
    writeln(o.m + "\t" + o.j +"\t"+ o.pos +"\t" + o.pt +"\t"+ o.e  +"\t"+ o.v  
    +"\t"+ itvO[o].start  +"\t"+ itvO[o].end);
    	
};
    