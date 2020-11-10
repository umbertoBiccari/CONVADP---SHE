
clear all;
%% Take a values of modulation index 

%% Create Solver

harmonics = [1 3 5 7]';
Ns = {50 50 50 50};
Dim = length(Ns);

for idim = 1:Dim
    bT_span{idim} = linspace(-2,2,Ns{idim});
    bT_ms{idim} = [];
    bT_ms_interp{idim} = [];

    bT_ms_2{idim} = [];
    Linspaces{idim} = 1:Ns{idim};
end

[bT_ms{:}] = ndgrid(bT_span{:});
%
Nf = 3;
f_span = linspace(-1,1,Nf);

Nt = 20;
T = pi/2;
tspan = linspace(0,T,Nt);
dt = tspan(2) - tspan(1);
%%
[bT_ms_2{:},f_ms_2] = ndgrid(bT_span{:},f_span);

for idim = 1:Dim
    F2{idim} = @(t) bT_ms_2{idim} -dt*(4/pi)*sin(harmonics(idim)*t).*f_ms_2;
end

%%
V = zeros(Ns{:},Nt);
%
for idim = 1:Dim
    V(Linspaces{:},Nt) = V(Linspaces{:},Nt) + 0.5*bT_ms{idim}.^2;
end
%V(V<1e-4) = 0;

perm = Linspaces;


for idim = 1:Dim
    for jdim = 1:Dim
        perm{idim,jdim} = 1;
    end
end
for idim = 1:Dim
    perm{idim,idim} = Linspaces{idim};
end

for it = (Nt-1):-1:1

    for idim = 1:Dim
        bTn_ms{idim}   = F2{idim}(tspan(it));
        
        bTn_span{idim} = reshape(bTn_ms{idim}(perm{:,idim},1:Nf),Ns{idim},Nf);
        [~,ind{idim}]  = min(abs(bTn_span{idim} - reshape(bT_span{idim},1,1,Ns{idim})),[],3);
    end
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for ifs = 1:Nf
       
        for idim = 1:Dim
            indfs{idim} = ind{idim}(:,ifs);
        end
        Vf{ifs}  = V(indfs{:},it+1);
     
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    V(Linspaces{:},it) = min(cat(Dim+1,Vf{:}),[],Dim + 1);

    fprintf("iter = "+num2str(Nt-it)+"\n")
end

%%

bT_time = zeros(Dim,Nt);
bT_time(:,1)= rand(Dim,1);

f_time = zeros(1,Nt-1);

indexs = 1:Nf;

F = @(t,f) -(4/pi)*sin(harmonics*t)*f;

%%
[bT_ms_interp{:},tspan_interp] = ndgrid(bT_span{:},tspan);

Vq = griddedInterpolant(V,bT_ms_interp{:},tspan_interp);
%%  
for it = 2:(Nt)

   bTc = bT_time(:,it-1);
   for ifs = 1:Nf
        bTn = bTc + (2*dt)*F(tspan(it),f_span(ifs));
        for idim = 1:Dim
            [~,ind{idim}] = min(abs(bTn(idim) - bT_span{idim}));
        end

        Va(ifs) = V(ind{:},it);
   end
   
   [Va_min,ind_f] = min(Va);

   
   if sum(Va == Va_min) > 1 && it>2
       posibles_ind_f = indexs(Va == Va_min);
       w =randsample(2,1);
       switch 1
           case 1
                if ismember(f_time(it-2),f_span(posibles_ind_f))
                   ind_f = find(f_time(it-2) == f_span);
                else
                   ind_f = randsample(posibles_ind_f,1);
                end
           case 2
               %
               [vv,newposibles] = min(abs(f_time(it-2) - f_span(posibles_ind_f)));
               ind_f = posibles_ind_f(newposibles);
           case 3
               ind_f = randsample(posibles_ind_f,1);
       end
   end
    

   f_time(it-1)  = f_span(ind_f);
   bT_time(:,it) = bT_time(:,it-1) + dt*F(tspan(it),f_span(ind_f));
   
    
end

%
figure(2)
clf

subplot(2,1,1)
hold on 
plot(bT_time')
yline(0)

for idim = 1:Dim
    plots{idim}= plot(1,bT_time(idim,1),'Marker','.','MarkerSize',30,'Color','g');
end


subplot(2,1,2)
hold on
plot(tspan(1:end-1),f_time)
fplot = plot(1,f_time(1),'Marker','.','MarkerSize',30,'Color','g');

yline(0)
ylim([-2 2])

for it = 2:1:(Nt)

    for idim = 1:Dim
       plots{idim}.XData = it;
       plots{idim}.YData = bT_time(idim,it);
    end
    
   
   fplot.XData = tspan(it-1);
   fplot.YData = f_time(it-1);

   pause(0.01)
    
end
%%

