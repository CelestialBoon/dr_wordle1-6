def parse_vec file
  v = {}
  file.split("\n").each do |s|
    arr = s.split(":")
    v[arr[0]] = arr[1].gsub("[", "").gsub("]", "").split(",").map(&:to_i)
  end
  v
end
  
def parse_inv file
  v = {}
  file.split("\r\n").each do |s|
    arr = s.split(":")
    v[arr[0]] = arr[1].gsub("{", "").gsub("}", "").split(", ").map do |st| st.gsub("'", '') end
  end
  v
end
  
def parse_tweets file
  d = {}
  file.split("\r\n").each do |ln| 
    parts = ln.split ";"
    day = parts[0].to_i
    id = parts[1]
    guesses = parts[2]
      .gsub("[", "").gsub("]", "")
      .split(", ").map {|st| st.gsub("'", '')}
    d[day] ||= {}
    d[day][id] = guesses
  end
  d
end
  
def cosine(v1, v2)
  dot_product = 0
  v1.zip(v2).each do |v1i, v2i|
    dot_product += v1i * v2i
  end
  a = v1.map { |n| n ** 2 }.reduce(:+)
  b = v2.map { |n| n ** 2 }.reduce(:+)
  return dot_product / (Math.sqrt(a) * Math.sqrt(b))
end

def counter list
  counts = {}
  for l in list do
    counts[l] ||= 0
    counts[l] = counts[l] +1
  end
  counts
end
  
def evaluate_guess(answer, guess)
  res = ['','','','','']
  matches = {}
  gue_c = guess.chars
  ans_c = answer.chars
  ans_letters = counter(ans_c)
  gue_c.each {|c| matches[c] = 0}
  
  gue_c.each_with_index do |c, i| 
    if answer[i]==c
      res[i] = 'Y'
      matches[c] += 1
    end
  end
  
  gue_c.each_with_index do |c, i| 
    if res[i] != 'Y'
      if ans_c.include? c && matches[c] < (ans_letters[c] || 0)
        res[i] = 'M'
        mathces[c] += 1
      else res[i] = 'N'
      end
    end
  end
  res
end


def tick args

  args.state.process_fiber ||= Fiber.new do

    letters = ['Y', 'M', 'N']
    vec_locs = letters.product(letters).product(letters).product(letters).product(letters)
        .map {|arr| arr.flatten.join('') }.sort
        
    Fiber.yield "Loading general vectors..."
    args.state.v_all ||= parse_vec(args.gtk.read_file("data/vec_all.txt"))
    
    Fiber.yield "Loading ratio vectors..."
    args.state.v_ratio ||= parse_vec(args.gtk.read_file("data/vec_ratio.txt"))
    
    Fiber.yield "Loading possible answers..."
    args.state.answers ||= args.gtk.read_file("data/answers.txt").split("\r\n")
    
    Fiber.yield "Loading other valid words..."
    args.state.other_words ||= args.gtk.read_file("data/other_words.txt").split("\r\n")
    
    Fiber.yield "Loading valid responses..."
    args.state.invalid_results ||= parse_inv(args.gtk.read_file("data/invalid_results.txt"))
    
    Fiber.yield "Loading tweets..."
    args.state.tweets ||= parse_tweets(args.gtk.read_file("data/tweets.txt"))

    # args.state.v_all ||= {cigar:[2, 27, 0, 10, 31, 0, 0, 0, 0, 1, 20, 0, 10, 24, 5, 0, 7, 0, 0, 0, 0, 5, 1, 0, 0, 0, 0, 1, 33, 0, 5, 14, 2, 0, 23, 0, 6, 10, 0, 7, 90, 14, 0, 16, 1, 0, 8, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 7, 0, 1, 19, 0, 0, 9, 0, 0, 0, 0, 0, 89, 0, 0, 0, 0, 14, 76, 0, 18, 91, 2, 0, 58, 0, 6, 19, 0, 6, 73, 41, 0, 29, 0, 10, 0, 0, 7, 9, 2, 0, 7, 0, 3, 120, 4, 22, 136, 10, 0, 29, 41, 34, 60, 16, 3, 184, 67, 1, 43, 79, 3, 7, 0, 0, 3, 0, 0, 10, 55, 4, 30, 0, 2, 48, 1, 0, 8, 39, 4, 14, 0, 18, 74, 49, 2, 20, 37, 0, 0, 0, 13, 47, 40, 0, 3, 0, 24, 34, 0, 2, 44, 0, 0, 2, 0, 18, 1, 0, 5, 18, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 84, 27, 47, 0, 0, 20, 0, 3, 6, 2, 7, 25, 7, 0, 24, 31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 34, 0, 0, 0, 0, 0, 0, 0, 0, 0, 61, 7, 0, 1, 2, 0, 0, 0, 0, 1, 0, 0, 0, 995], rebut:[16, 10, 0, 6, 14, 36, 0, 0, 0, 10, 5, 0, 11, 24, 3, 0, 0, 0, 1, 3, 0, 0, 6, 0, 0, 0, 0, 143, 65, 20, 48, 14, 25, 0, 0, 0, 24, 30, 4, 8, 54, 4, 0, 2, 0, 0, 2, 2, 7, 0, 0, 0, 0, 0, 0, 45, 0, 0, 45, 48, 0, 0, 0, 0, 14, 0, 0, 33, 3, 0, 3, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 20, 13, 8, 20, 45, 0, 0, 0, 106, 10, 6, 38, 49, 22, 5, 10, 54, 0, 0, 0, 0, 1, 0, 0, 0, 0, 63, 43, 21, 16, 72, 21, 14, 11, 1, 33, 93, 22, 40, 113, 20, 21, 12, 11, 16, 2, 0, 9, 3, 0, 0, 4, 0, 7, 48, 0, 70, 13, 28, 0, 10, 0, 0, 29, 34, 15, 43, 17, 8, 18, 0, 0, 7, 0, 15, 3, 8, 0, 20, 114, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 12, 0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 23, 26, 0, 1, 5, 0, 0, 0, 0, 0, 10, 0, 6, 7, 16, 3, 0, 0, 0, 0, 0, 0, 0, 12, 0, 1, 0, 0, 0, 0, 0, 44, 0, 0, 0, 0, 0, 35, 0, 10, 107, 311, 0, 116, 85, 0, 0, 0, 0, 60, 4, 0, 38, 883]}
    # args.state.v_ratio ||= {cigar:[0.99999950000025, 0.5925925706447196, 0.0, 0.599999940000006, 0.29032257127991706, 0.0, 0.0, 0.0, 0.0, 0.0, 0.04999999750000012, 0.0, 0.19999998000000202, 0.08333332986111125, 0.599999880000024, 0.0, 0.57142848979593, 0.0, 0.0, 0.0, 0.0, 0.599999880000024, 0.9999990000010001, 0.0, 0.0, 0.0, 0.0, 0.9999990000010001, 0.30303029384756686, 0.0, 0.0, 0.0, 0.99999950000025, 0.0, 0.17391303591682453, 0.0, 0.0, 0.09999999000000101, 0.0, 0.0, 0.0, 0.21428569897959293, 0.0, 0.24999998437500096, 0.0, 0.0, 0.4999999375000079, 0.0, 0.0, 0.24999993750001562, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7499999062500118, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4285713673469475, 0.0, 0.9999990000010001, 0.15789472853185638, 0.0, 0.0, 0.9999998888889013, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7078651605857847, 0.0, 0.0, 0.0, 0.0, 0.6428570969387788, 0.1973684184556787, 0.0, 0.1666666574074079, 0.021978021736505256, 0.499999750000125, 0.0, 0.46551723335315115, 0.0, 0.0, 0.15789472853185638, 0.0, 0.0, 0.0, 0.0, 0.0, 0.24137930202140337, 0.0, 0.99999990000001, 0.0, 0.0, 0.4285713673469475, 0.11111109876543349, 0.0, 0.0, 0.7142856122449125, 0.0, 0.33333322222225925, 0.024999999791666668, 0.49999987500003124, 0.045454543388429844, 0.0, 0.299999970000003, 0.0, 0.24137930202140337, 0.8292682724568714, 0.0, 0.016666666388888893, 0.24999998437500096, 0.0, 0.0, 0.10447761038093119, 0.9999990000010001, 0.11627906706327752, 0.4556961967633393, 0.9999996666667778, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.39999996000000404, 0.9454545282644632, 0.9999997500000625, 0.6999999766666675, 0.0, 0.99999950000025, 0.08333333159722227, 0.9999990000010001, 0.0, 0.8749998906250137, 0.9743589493754116, 0.7499998125000469, 0.14285713265306196, 0.0, 0.27777776234567986, 0.040540539992695405, 0.6122448854643902, 0.99999950000025, 0.5999999700000015, 0.8648648414901394, 0.0, 0.0, 0.0, 0.9999999230769291, 0.3617021199637847, 0.8499999787500006, 0.0, 0.9999996666667778, 0.0, 0.999999958333335, 0.7058823321799315, 0.0, 0.99999950000025, 0.22727272210743815, 0.0, 0.0, 0.99999950000025, 0.0, 0.6666666296296316, 0.9999990000010001, 0.0, 0.799999840000032, 0.055555552469135974, 0.0, 0.0, 0.7999999466666703, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.36842103324099823, 0.9999999880952383, 0.4074073923182447, 0.04255319058397467, 0.0, 0.0, 0.8999999550000022, 0.0, 0.6666664444445185, 0.0, 0.99999950000025, 0.0, 0.03999999840000006, 0.0, 0.0, 0.4999999791666675, 0.9999999677419364, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9999990000010001, 0.0, 0.9999999705882362, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6557376941682346, 0.9999998571428775, 0.0, 0.9999990000010001, 0.99999950000025, 0.0, 0.0, 0.0, 0.0, 0.9999990000010001, 0.0, 0.0, 0.0, 0.0], rebut:[0.4374999726562517, 0.299999970000003, 0.0, 0.16666663888889352, 0.0, 0.4999999861111115, 0.0, 0.0, 0.0, 0.599999940000006, 0.0, 0.0, 0.0, 0.041666664930555625, 0.33333322222225925, 0.0, 0.0, 0.0, 0.9999990000010001, 0.33333322222225925, 0.0, 0.0, 0.33333327777778704, 0.0, 0.0, 0.0, 0.0, 0.027972027776419387, 0.015384615147928998, 0.2499999875000006, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.49999987500003124, 0.0, 0.0, 0.0, 0.0, 0.499999750000125, 0.0, 0.0, 0.0, 0.99999950000025, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.46666665629629656, 0.0, 0.0, 0.06666666518518523, 0.9999999791666672, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.030303029384756687, 0.6666664444445185, 0.0, 0.9999996666667778, 0.99999980000004, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.199999960000008, 0.04999999750000012, 0.0, 0.12499998437500197, 0.0, 0.1555555520987655, 0.0, 0.0, 0.0, 0.0377358487006052, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.092592590877915, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.09523809070294806, 0.0, 0.0, 0.0, 0.3571428316326549, 0.0, 0.9999990000010001, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1818181652892577, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.24999993750001562, 0.0, 0.9999998571428775, 0.20833332899305565, 0.0, 0.1285714267346939, 0.0, 0.5357142665816333, 0.0, 0.09999999000000101, 0.0, 0.0, 0.0, 0.23529411072664383, 0.06666666222222252, 0.0, 0.05882352595155729, 0.4999999375000079, 0.055555552469135974, 0.0, 0.0, 0.57142848979593, 0.0, 0.7999999466666703, 0.0, 0.9999998750000157, 0.0, 0.7499999625000018, 0.9999999912280703, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.41666663194444736, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.499999750000125, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6521738846880919, 0.07692307396449716, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.12499999218750048, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8333332638888947, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4999999886363639, 0.0, 0.0, 0.0, 0.0, 0.0, 0.428571416326531, 0.0, 0.39999996000000404, 0.21495326901912834, 0.5884244354069954, 0.0, 0.5258620644322236, 0.9999999882352942, 0.0, 0.0, 0.0, 0.0, 0.6833333219444446, 0.9999997500000625, 0.0, 0.8157894522160671, 0.0]}
    # args.state.answers ||= [:cigar]
    # args.state.other_words ||= [:rebut]
    # args.state.invalid_results ||= {cigar:["MMMYY", "NYYMY", "MMYYN", "YMYYY", "YMNYM", "YYYNM", "MMYYM", "MMNMY", "NYYMM", "NYNMY", "MNYMY", "MYMYN", "YNNYM", "YMYMM", "YYYMM", "YYYYN", "YNYMY", "YMNYY", "MYYMY", "YYMNY", "MYNYM", "NYYYM", "MYYMN", "YYMYY", "YYMYN", "YYYNY", "MYMYY", "NMYYY", "NMMMY", "YYNMY", "YMYYM", "YNYNY", "MYYYY", "MYMYM", "MYMNY", "NMYYM", "YMYNM", "NNYYM", "YYNMN", "MMYNY", "YMNMY", "YYMYM", "MMYYY", "MNYYY", "NYMMY", "YMMMY", "MYYMM", "YYYYM", "NNYMY", "NYMYM", "NYYMN", "MYNYY", "MMMYN", "MYMMY", "MMNYY", "YMYYN", "MYYYM", "YYNMM", "YYYMY", "YNYMM", "MYYNM", "NMMYY", "YNYYM", "MYNMY", "YYMMY", "MMMMY", "NYYYY", "MNYYM", "YMYMY", "MNMYY", "MYYYN", "YMMYY", "YYMMM", "YNMYY", "YMYMN", "YMMYM", "YYNYM", "MMMYM", "YNYNM", "YNYYY", "MYYNY", "MYMMM", "MMYMM", "YMMNY", "YYYMN", "YNYYN", "MMNYM", "MMYMY", "YNMYM"], rebut:["MMMYY", "NYYMY", "MMYYN", "YMYYY", "YMNYM", "YYYNM", "NNYYY", "MMYYM", "MMNMY", "YMMNM", "MNYNY", "NYYMM", "MYMYN", "YMYMM", "YYYMM", "YNYMY", "YMNYY", "MYYMY", "NYMYY", "YYMNY", "MYNYM", "YMMMM", "MYYMN", "YYMYY", "YYMYN", "MYMYY", "NMYYY", "YYNMY", "YMMYN", "YMYYM", "NMYYN", "MYMYM", "MYYYY", "NMYYM", "YNMMY", "MMYNY", "YMNMY", "YYMYM", "MMYYY", "MNYYY", "NYMMY", "YMMMY", "MYYMM", "YYYYM", "NYMYM", "MMMYN", "MYMMY", "MMNYY", "YMYYN", "MYYYM", "NMYMY", "YYNMM", "YYYMY", "YNYMM", "MYYNM", "YYMMN", "YMNNY", "NMMYY", "NMMYM", "MNMYM", "YNYYM", "MYNMY", "NYNYY", "YYMMY", "MNYYM", "YMYMY", "MNMYY", "MYYYN", "YYMNM", "YMMYY", "YMNYN", "YYMMM", "YNMYY", "MYNMM", "YMMYM", "MYYNN", "MMMYM", "YNYYY", "YMYNY", "MYYNY", "MYMMM", "YNNYY", "YMMNY", "YYYMN", "MMNYM", "MMYMY", "YNMYM"]}
    # args.state.tweets ||= {0 => {1482553374591660037 => ["MNNNN", "YYYYY"], 1482553374591660038 => ["MNNNN", "YYYYY"], 1482553374591660039 => ["MNNNN", "NNNNN"]}}

  #   # args.state.tweets.each do |day, games|
  #   # if day != 210 { next }
    
    day = 210
    games = args.state.tweets[day].map{|id, g| g}

    Fiber.yield "Preparing data..."
    all_counts = counter(games.find_all {|g| g.length > 1 && g[-1] == "YYYYY"}.flatten )
    first_counts = counter(games.find_all {|g| g.length > 1 && g[-1] == "YYYYY"}.map {|g| g[0]})
    penultimate_counts = counter(games.find_all {|g| g.length > 1 && g[-1] == "YYYYY"}.map {|g| g[-2]})
    
    vec_all = vec_locs.map {|res| all_counts[res] || 0}
    vec_first = vec_locs.map {|res| first_counts[res] || 0}
    vec_penultimate = vec_locs.map {|res| penultimate_counts[res] || 0}
    vec_ratio = vec_locs.map {|res| (penultimate_counts[res] || 0)/((all_counts[res] || 0)+1e-6)}
    
    list_length = args.state.v_all.length
    list_i = 0
    dists = {"all" => {}, "ratio" => {}, "invalid" => {}}
    args.state.v_all.each_key do |word|
      Fiber.yield "Calculating distances... (#{list_i}/#{list_length})"
      list_i +=1
      dists["all"][word] = cosine(vec_all, args.state.v_all[word])
      dists["ratio"][word] = cosine(vec_ratio, args.state.v_ratio[word])
      dists["invalid"][word] = games.find_all {|g| !(g & args.state.invalid_results[word]).empty? }.length
    end
    
    Fiber.yield "Sorting results..."
    ranks = {}
    dists.each do |type, value|
      s = value.sort_by{|k, v| -v}
      ranks[type] = {} 
      s.length.times {|i| ranks[type][s[i][0]] = i}
    end
    
    overall = {}
    args.state.v_all.each_key do |key|
      overall[key] = ranks.map {|k, v| v[key]}
    end

    overall_s = overall.sort_by {|k, v| v}
    my_guess = overall_s[0][0]
    answer = args.state.answers[day]
    answer_rank = overall_s.map {|a| a[0]}.index(answer)

    # hash = {day: day, guess: my_guess, answer: answer, rank: answer_rank, overall: overall, dists: dists, ranks: ranks}
    # Fiber.yield hash

    feedback = evaluate_guess(answer.to_s, my_guess.to_s).join
    
    if answer==my_guess
      feedback.concat(" !!!!!!")
    else
      feedback.concat(" :(:( the actual answer was #{answer}, which ranked #{answer_rank} on my guess list")
    end
    
    # puts("For Wordle #{day}, my guess was #{my_guess}. #{feedback}")
    "Guessed for day #{day}, my guess is #{my_guess}, #{feedback}"
  end

  if args.state.process_fiber.alive?
    args.state.result = args.state.process_fiber.resume
  end

  args.outputs.labels  << [640, 500, args.state.result, 5, 1]
end

