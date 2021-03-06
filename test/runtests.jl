using QMSimFiles
using Test

snpmap1 = "lm_mrk_001.txt"
qtlmap1 = "lm_qtl_001.txt"
qtleff1 = "effect_qtl_001.txt"
snpdata1 = "p1_mrk_001.txt"
snpdata2 = "p1_mrk_002.txt"   # saved as /snp_code
qtldata1 = "p1_qtl_001.txt"

@testset "get_number_of_chromosomes" begin
   nchr = QMSimFiles.get_number_of_chromosomes(snpmap1)
   @test nchr == 3
   nchr = QMSimFiles.get_number_of_chromosomes(qtlmap1)
   @test nchr == 3
end

@testset "get_number_of_loci" begin
   nchr = QMSimFiles.get_number_of_chromosomes(snpmap1)
   nloci = QMSimFiles.get_number_of_loci(snpmap1,nchr)
   @test all( nloci == [4,3,4] )
   nchr = QMSimFiles.get_number_of_chromosomes(qtlmap1)
   nloci = QMSimFiles.get_number_of_loci(qtlmap1,nchr)
   @test all( nloci == [3,4,2] )
end

@testset "get_number_of_QTL_allele" begin
   maxna,maxAllele = QMSimFiles.get_number_of_QTL_allele(qtleff1,3)
   @test maxna == 4
   @test all( maxAllele .== [4,4,3] )
end

@testset "load_SNP_QTL_maps!" begin
   maxna,maxAllele = QMSimFiles.get_number_of_QTL_allele(qtleff1,3)
   maps = Vector{QMSimFiles.QMSimChromosomeMap}(undef,3)
   maps[1] = QMSimFiles.QMSimChromosomeMap(7,4,3,zeros(Int,7),zeros(Float64,7),maxAllele[1],zeros(Int,maxAllele[1]),zeros(Float64,maxAllele[1],3))
   maps[2] = QMSimFiles.QMSimChromosomeMap(7,3,4,zeros(Int,7),zeros(Float64,7),maxAllele[2],zeros(Int,maxAllele[2]),zeros(Float64,maxAllele[2],4))
   maps[3] = QMSimFiles.QMSimChromosomeMap(6,4,2,zeros(Int,6),zeros(Float64,6),maxAllele[3],zeros(Int,maxAllele[3]),zeros(Float64,maxAllele[3],2))
   QMSimFiles.load_SNP_QTL_maps!(snpmap1,qtlmap1,maps)
   @test all( maps[1].seqQTL .== [0,0,0,0,1,2,3] )
   @test all( maps[2].seqQTL .== [0,0,0,4,5,6,7] )
   @test all( maps[3].seqQTL .== [0,0,0,0,8,9] )
   @test all( maps[1].pos .≈ [5.99360,46.98708,71.46866,78.57678, 23.76397,28.15399,89.81130] )
   @test all( maps[2].pos .≈ [8.92501,13.56385,43.67896, 29.88287,38.45590,66.06151,82.55315] )
   @test all( maps[3].pos .≈ [25.60614,86.19237,91.47393,98.69095, 14.34842,24.60904] )
   omaps = deepcopy(maps)

   QMSimFiles.sort_by_position!(maps[1].pos, maps[1].seqQTL)
   QMSimFiles.sort_by_position!(maps[2].pos, maps[2].seqQTL)
   QMSimFiles.sort_by_position!(maps[3].pos, maps[3].seqQTL)
   perm1 = [1,5,6,2,3,4,7]
   perm2 = [1,2,4,5,3,6,7]
   perm3 = [5,6,1,2,3,4]
   @test all( maps[1].seqQTL .== omaps[1].seqQTL[perm1] )
   @test all( maps[2].seqQTL .== omaps[2].seqQTL[perm2] )
   @test all( maps[3].seqQTL .== omaps[3].seqQTL[perm3] )
   @test all( maps[1].pos .≈ omaps[1].pos[perm1] )
   @test all( maps[2].pos .≈ omaps[2].pos[perm2] )
   @test all( maps[3].pos .≈ omaps[3].pos[perm3] )
end

@testset "load_QTL_effect! and read_maps" begin
   maxna,maxAllele = QMSimFiles.get_number_of_QTL_allele(qtleff1,3)
   maps = Vector{QMSimFiles.QMSimChromosomeMap}(undef,3)
   maps[1] = QMSimFiles.QMSimChromosomeMap(7,4,3,zeros(Int,7),zeros(Float64,7),maxAllele[1],zeros(Int,3),zeros(Float64,maxAllele[1],3))
   maps[2] = QMSimFiles.QMSimChromosomeMap(7,3,4,zeros(Int,7),zeros(Float64,7),maxAllele[2],zeros(Int,4),zeros(Float64,maxAllele[2],4))
   maps[3] = QMSimFiles.QMSimChromosomeMap(6,4,2,zeros(Int,6),zeros(Float64,6),maxAllele[3],zeros(Int,2),zeros(Float64,maxAllele[3],2))
   QMSimFiles.load_SNP_QTL_maps!(snpmap1,qtlmap1,maps)
   QMSimFiles.sort_by_position!(maps[1].pos, maps[1].seqQTL)
   QMSimFiles.sort_by_position!(maps[2].pos, maps[2].seqQTL)
   QMSimFiles.sort_by_position!(maps[3].pos, maps[3].seqQTL)

   QMSimFiles.load_QTL_effect!(qtleff1,maps)
   @test all( maps[1].naQTL .== [3,4,4] )
   @test all( maps[2].naQTL .== [3,4,2,2] )
   @test all( maps[3].naQTL .== [3,3] )
   @test all( maps[1].effQTL[1:3,1] .≈ [-0.177111,-0.223061,0.071867] )
   @test all( maps[1].effQTL[1:4,2] .≈ [0.034120,-0.053426,-0.032978,0.022941] )
   @test all( maps[1].effQTL[1:4,3] .≈ [-0.010957,-0.001999,0.033815,-0.010451] )
   @test all( maps[2].effQTL[1:3,1] .≈ [0.054960,-0.038202,-0.063630] )
   @test all( maps[2].effQTL[1:4,2] .≈ [0.130199,0.137865,-0.455851,0.296964] )
   @test all( maps[2].effQTL[1:2,3] .≈ [0.001240,-0.000023] )
   @test all( maps[2].effQTL[1:2,4] .≈ [-0.071812,0.063439] )
   @test all( maps[3].effQTL[1:3,1] .≈ [-0.020500,0.004283,-0.075465] )
   @test all( maps[3].effQTL[1:3,2] .≈ [0.004419,-0.010919,0.021111] )

   refmap = read_maps(snpmap1,qtlmap1,qtleff1)
   @test refmap.nchr == 3
   @test refmap.totalSNP == 11
   @test refmap.totalQTL == 9
   for i in 1:3
      @test refmap.chr[i].nLoci == maps[i].nLoci
      @test refmap.chr[i].nSNP == maps[i].nSNP
      @test refmap.chr[i].nQTL == maps[i].nQTL
      @test all( refmap.chr[i].seqQTL .== maps[i].seqQTL )
      @test all( refmap.chr[i].pos .≈ maps[i].pos )
      @test refmap.chr[i].maxAllele .== maps[i].maxAllele
      @test all( refmap.chr[i].naQTL .== maps[i].naQTL )
      @test all( refmap.chr[i].effQTL .≈ maps[i].effQTL )
   end
end

@testset "generate_chromosome_set" begin
   gmap = read_maps(snpmap1,qtlmap1,qtleff1)
   chromosome_set = QMSimFiles.generate_chromosome_set(gmap)
   @test length(chromosome_set)==gmap.nchr
end

@testset "parse SNP/QTL data" begin
   gmap = read_maps(snpmap1,qtlmap1,qtleff1)
   @test QMSimFiles.is_snpcode_file(snpdata1,gmap.totalSNP)==false
   @test QMSimFiles.is_snpcode_file(snpdata2,gmap.totalSNP)==true

   # for SNP (standard)
   stext = "2       2 1 2 2 1 1 1 1 1 1 1 1 1 1 1 2 1 1 1 2 1 1"
   snp = zeros(Int8,gmap.totalSNP*2)
   QMSimFiles.text_to_code!(stext,gmap.totalSNP,snp,7)
   @test all( snp .== [2, 1, 2, 2, 1, 1, 1, 1,   1, 1, 1, 1, 1, 1,   1, 2, 1, 1, 1, 2, 1, 1] )

   chromosome_set1 = QMSimFiles.generate_chromosome_set(gmap)
   QMSimFiles.convert_snpdata_to_haplotype!(snp,gmap,chromosome_set1)
   @test all( chromosome_set1[1].gp[findall(x->gmap.chr[1].seqQTL[x]==0,1:gmap.chr[1].nLoci)] .== [1,1,0,0] )
   @test all( chromosome_set1[1].gm[findall(x->gmap.chr[1].seqQTL[x]==0,1:gmap.chr[1].nLoci)] .== [0,1,0,0] )
   @test all( chromosome_set1[2].gp[findall(x->gmap.chr[2].seqQTL[x]==0,1:gmap.chr[2].nLoci)] .== [0,0,0] )
   @test all( chromosome_set1[2].gm[findall(x->gmap.chr[2].seqQTL[x]==0,1:gmap.chr[2].nLoci)] .== [0,0,0] )
   @test all( chromosome_set1[3].gp[findall(x->gmap.chr[3].seqQTL[x]==0,1:gmap.chr[3].nLoci)] .== [0,0,0,0] )
   @test all( chromosome_set1[3].gm[findall(x->gmap.chr[3].seqQTL[x]==0,1:gmap.chr[3].nLoci)] .== [1,0,1,0] )
 
   # for SNP (snp_code)
   ctext = "2      42000003030"
   snp_code = zeros(Int8,gmap.totalSNP)
   QMSimFiles.text_to_snpcode!(ctext,gmap.totalSNP,snp_code,7)
   @test all( snp_code .== [4,2,0,0, 0,0,0, 3,0,3,0] )

   chromosome_set2 = QMSimFiles.generate_chromosome_set(gmap)
   QMSimFiles.convert_snpcode_to_haplotype!(snp_code,gmap,chromosome_set2)
   @test all( chromosome_set2[1].gp .== chromosome_set1[1].gp )
   @test all( chromosome_set2[1].gm .== chromosome_set1[1].gm )
   @test all( chromosome_set2[2].gp .== chromosome_set1[2].gp )
   @test all( chromosome_set2[2].gm .== chromosome_set1[2].gm )
   @test all( chromosome_set2[3].gp .== chromosome_set1[3].gp )
   @test all( chromosome_set2[3].gm .== chromosome_set1[3].gm )
   
   # for QTL
   qtext = "2       2 2 2 4 4 1 1 1 2 1 2 2 2 2 2 1 1 2"
   qtl = zeros(Int8,gmap.totalQTL*2)
   QMSimFiles.text_to_code!(qtext,gmap.totalQTL,qtl,7)
   @test all( qtl .== [2, 2, 2, 4, 4, 1,   1, 1, 2, 1, 2, 2, 2, 2,   2, 1, 1, 2] )

   QMSimFiles.convert_qtldata_to_haplotype!(qtl,gmap,chromosome_set2)
   @test all( chromosome_set2[1].gp[findall(x->gmap.chr[1].seqQTL[x]>0,1:gmap.chr[1].nLoci)] .== [2,2,4] )
   @test all( chromosome_set2[1].gm[findall(x->gmap.chr[1].seqQTL[x]>0,1:gmap.chr[1].nLoci)] .== [2,4,1] )
   @test all( chromosome_set2[2].gp[findall(x->gmap.chr[2].seqQTL[x]>0,1:gmap.chr[2].nLoci)] .== [1,2,2,2] )
   @test all( chromosome_set2[2].gm[findall(x->gmap.chr[2].seqQTL[x]>0,1:gmap.chr[2].nLoci)] .== [1,1,2,2] )
   @test all( chromosome_set2[3].gp[findall(x->gmap.chr[3].seqQTL[x]>0,1:gmap.chr[3].nLoci)] .== [2,1] )
   @test all( chromosome_set2[3].gm[findall(x->gmap.chr[3].seqQTL[x]>0,1:gmap.chr[3].nLoci)] .== [1,2] )

   # general function
   g1 = read_genotypes(snpdata1,qtldata1,gmap)
   g2 = read_genotypes(snpdata2,qtldata1,gmap)
   for i=1:3
      @test all( g1[2].chr[i].gp .== chromosome_set2[i].gp )
      @test all( g1[2].chr[i].gm .== chromosome_set2[i].gm )
      @test all( g2[2].chr[i].gp .== chromosome_set2[i].gp )
      @test all( g2[2].chr[i].gm .== chromosome_set2[i].gm )
   end
   @test isapprox(g1[1].tbv, -0.412531, atol=1e-5)
   @test isapprox(g1[2].tbv, -0.015914, atol=1e-5)
   @test isapprox(g1[3].tbv, -0.137409, atol=1e-5)
   @test isapprox(g1[4].tbv, -0.242572, atol=1e-5)
   for i=1:4
      @test g1[i].tbv ≈ g2[i].tbv
   end
end

@testset "number_of_crosses" begin
   g = read_qmsim_data(snpmap1,qtlmap1,qtleff1,snpdata2,qtldata1)
   chr = g.map.chr[1]
   refpos = [5.9936, 23.76397, 28.15399, 46.98708, 71.46866, 78.57678, 89.8113]
   n = QMSimFiles.number_of_crosses(chr.pos[end])
   @test (0 <= n) && (n <= 100)
end

@testset "location_of_crossover" begin
   g = read_qmsim_data(snpmap1,qtlmap1,qtleff1,snpdata2,qtldata1)
   chr = g.map.chr[1]
   ntests = 10
   for i=1:ntests
      chrlen = chr.pos[end]
      ncross = QMSimFiles.number_of_crosses(chrlen) + 1
      (ncross,gameteid,loccross) = QMSimFiles.location_of_crossover(chrlen,chr.pos,ncross)
      if ncross>0
         @test issorted(loccross) && (loccross[1]>=0) && (loccross[end]<=chrlen) && length(loccross)==ncross
         @test all( map(x -> ((gameteid[x][1] in [1,2]) && gameteid[x][2] in [3,4]), 1:ncross ) ) && length(gameteid)==ncross
      end
   end
   # adjustment to remove double cross etc
   gameteid = [(1,3),(1,3),(1,4),(1,4),(2,3),(2,3),(2,4),(2,4)]
   loccross = [1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0]
   (ncross2,gameteid2,loccross2) = QMSimFiles.adjusted_location_of_crossover(gameteid,loccross)
   @test ncross2==0

   gameteid = [(1,3),(1,3),(1,4),(1,4),(1,4),(1,4),(2,4),(2,4)]
   loccross = [1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0]
   (ncross2,gameteid2,loccross2) = QMSimFiles.adjusted_location_of_crossover(gameteid,loccross)
   @test ncross2==0

   gameteid = [(2,3),(1,3),(1,4),(1,3),(2,3),(1,3),(2,4),(1,4),(2,4)]
   loccross = [1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0,  9.0]
   (ncross2,gameteid2,loccross2) = QMSimFiles.adjusted_location_of_crossover(gameteid,loccross)
   @test ncross2==1

   gameteid = [(2,3),(1,3),(1,4),(1,3),(2,3),(1,3),(2,4),(1,4),(2,4),(2,3),(1,4)]
   loccross = [1.0,  2.0,  3.0,  4.0,  5.0,  6.0,  7.0,  8.0,  9.0,  10.0, 11.0]
   (ncross2,gameteid2,loccross2) = QMSimFiles.adjusted_location_of_crossover(gameteid,loccross)
   @test ncross2==3
end

@testset "generate_gamete_with_crossover" begin
   g = read_qmsim_data(snpmap1,qtlmap1,qtleff1,snpdata2,qtldata1)
   chr = g.map.chr[1]
   chrlen = chr.pos[end]
   refpos = [5.9936, 23.76397, 28.15399, 46.98708, 71.46866, 78.57678, 89.8113]

   # refgp = [1, 3, 3, 0, 0, 0, 4]
   # refgm = [1, 3, 4, 0, 0, 1, 4]
   gp = g.individual[4].chr[1].gp
   gm = g.individual[4].chr[1].gm
   ncross = 1
   gameteid = [(1,3)]
   loccross = [3]
   ga = QMSimFiles.generate_gamete_with_crossover(gameteid,loccross,1,gp,gm)
   @test all( ga .== [1,3,4,0,0,1,4] )

   ncross = 2
   gameteid = [(1,3),(1,4)]
   loccross = [3,6]
   ga = QMSimFiles.generate_gamete_with_crossover(gameteid,loccross,1,gp,gm)
   @test all( ga .== [1,3,4,0,0,1,4] )
end

@testset "general mating" begin
   g = read_qmsim_data(snpmap1,qtlmap1,qtleff1,snpdata2,qtldata1)
   sumtbv = 0.0
   nanim = 1000
   for i=1:nanim
      animal = mating(g.map, g.individual[1], g.individual[2])
      sumtbv = sumtbv + animal.tbv
   end
   pa = (g.individual[1].tbv + g.individual[2].tbv)/2
   @test isapprox(sumtbv/nanim,pa, atol=1e-1)
end

@testset "equal sign" begin
   g = read_qmsim_data(snpmap1,qtlmap1,qtleff1,snpdata2,qtldata1)
   @test g.map==g.map
   @test g.individual[1]==g.individual[1]
   @test !(g.individual[1]==g.individual[2])
end

@testset "pack/unpack genotypes" begin
   g = read_qmsim_data(snpmap1,qtlmap1,qtleff1,snpdata2,qtldata1)
   for k=1:length(g.individual)
      # pack
      ref_packed = zeros(Int8,0)
      for i=1:g.map.nchr
         ref_packed = [ref_packed; g.individual[k].chr[i].gp]
         ref_packed = [ref_packed; g.individual[k].chr[i].gm]
      end
      ind_packed = QMSimFiles.pack_genome(g.map,g.individual[k])
      @test all( ind_packed .== ref_packed )
      packed = QMSimFiles.pack_genome(g.map,g.individual[k].chr)
      @test all( packed .== ref_packed )

      # unpack
      chromosome_set = QMSimFiles.unpack_genome(g.map,packed)
      @test all( chromosome_set == g.individual[k].chr )
   end
end

@testset "save/read genotypes" begin
   g = read_qmsim_data(snpmap1,qtlmap1,qtleff1,snpdata2,qtldata1)

   #hdf5file = "runtests.h5"
   hdf5file = tempname()
   @info "temporary HDF5 file: $(hdf5file)"
   save_qmsim_data_hdf5(g,hdf5file)

   # map
   saved_map = read_qmsim_map_hdf5(hdf5file)
   @test saved_map == g.map

   # particular individual
   for i=1:length(g.individual)
      individual = QMSimFiles.read_qmsim_individual_hdf5(g.map,hdf5file,i)
      @test individual == g.individual[i]
   end

   # all genotypes
   genotypes = QMSimFiles.read_qmsim_all_genotypes_hdf5(g.map,hdf5file)
   @test g == QMSimPopulationGenome(g.map,genotypes)

   # whole data
   @test g == read_qmsim_data_hdf5(hdf5file)

   # added individual
   add_qmsim_individual_hdf5(g.map, hdf5file, g.individual[1])
   added = QMSimFiles.read_qmsim_individual_hdf5(g.map,hdf5file,5)
   @test added == g.individual[1]

   # size of saved genotypes
   @test get_qmsim_genotype_size(hdf5file) == (5, g.map.totalSNP + g.map.totalQTL)

   # empty hdf5 only with map
   hdf5file2 = tempname()
   @info "temporary HDF5 file: $(hdf5file2)"
   create_qmsim_map_hdf5(g.map, hdf5file2)

   saved_map = read_qmsim_map_hdf5(hdf5file2)
   @test saved_map == g.map

   add_qmsim_individual_hdf5(g.map, hdf5file2, g.individual[1])
   added = QMSimFiles.read_qmsim_individual_hdf5(g.map,hdf5file2,1)
   @test added == g.individual[1]
end

@testset "export to blupf90" begin
   g = read_qmsim_data(snpmap1,qtlmap1,qtleff1,snpdata2,qtldata1)
   @test String( QMSimFiles.pack_markrs(g.map,g.individual[2]) .+ UInt8(48)) == "12000001010"
   @test String( QMSimFiles.pack_markrs(g.map,g.individual[3]) .+ UInt8(48)) == "22220001120"

   snpfile = tempname()
   @info "temporary text file: $(snpfile)"
   if isfile(snpfile); rm(snpfile,force=true); end
   export_qmsim_individual_blupf90(g.map, 2, g.individual[2], snpfile)
   export_qmsim_individual_blupf90(g.map, 3, g.individual[3], snpfile)

   @test countlines(snpfile)==2
   open(snpfile,"r") do io
      # individual 2
      line = readline(io)
      items = split(line)
      @test items[1]=="2" && items[2]=="12000001010"
      # individual 3
      line = readline(io)
      items = split(line)
      @test items[1]=="3" && items[2]=="22220001120"
   end
end
