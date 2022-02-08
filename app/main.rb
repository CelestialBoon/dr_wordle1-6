DAY = 210

def tick args
  args.gtk.log_level = :off
  args.state.defaults_loaded ||= defaults args

  if args.state.process_fiber.alive?
    args.state.result = args.state.process_fiber.resume
  else
    args.outputs.labels << {
      x: 640, y: 360,
      text: args.state.result,
      size_enum: 5,
      alignment_enum: 1,
      vertical_alignment_enum: 1,
      r: 255, g: 255, b: 255
    }
  end

  args.outputs.background_color = args.state.bg

  if $sub_task[:state] == :dist_calc
    fragment = args.outputs[:fragment]
    fragment.clear_before_render = false
    fragment.w = 1180
    fragment.h = 540

    itp = $sub_task[:task] / $sub_task[:tasks]

    len = 1593
    i = (itp * len).to_i
    j = (itp * len) % 5 * 0.3 + 0.8 * rand

    bl = args.state.fragment_block
    bl[:x] = (i % 59) * 20
    bl[:y] = i.idiv(59) * 20
    bl[:r] = 55 * j
    bl[:g] = 155 * j
    bl[:b] = 255 * j

    fragment.sprites << bl
    args.outputs.sprites << args.state.fragment_sprite
  end

  if $task[:tasks]
    args.state.progress_bar[:fill].w = args.state.progress_bar[:main].w * ($task[:task] / $task[:tasks])
    args.state.progress_label.text = $task[:info]

    args.outputs.sprites << args.state.progress_bar[:main]
    args.outputs.sprites << args.state.progress_bar[:fill]
    args.outputs.labels << args.state.progress_label
  end

  if $sub_task[:tasks]
    args.state.sub_progress_bar[:fill].w = args.state.sub_progress_bar[:main].w * ($sub_task[:task] / $sub_task[:tasks])
    args.state.sub_progress_label.text = $sub_task[:info]

    args.outputs.sprites << args.state.sub_progress_bar[:main]
    args.outputs.sprites << args.state.sub_progress_bar[:fill]
    args.outputs.labels << args.state.sub_progress_label
  end
end

def defaults args
  args.state.process_fiber = create_process_fiber
  args.state.bg = [0, 0, 0]

  args.state.progress_bar = {}.tap do |progress_bar|
    progress_bar[:main] = {
      x: 60, y: 40,
      w: 1180, h: 40,
      path: :pixel,
      r: 25, g: 25, b: 25
    }
    progress_bar[:fill] = progress_bar[:main].merge w: 0, b: 175
  end

  args.state.sub_progress_bar = {}.tap do |sub_progress_bar|
    sub_progress_bar[:main] = {
      x: 60, y: 120,
      w: 1180, h: 20,
      path: :pixel,
      r: 25, g: 25, b: 25
    }
    sub_progress_bar[:fill] = sub_progress_bar[:main].merge w: 0, g: 75, b: 200
  end

  args.state.progress_label = {
    x: args.state.progress_bar[:main][:x],
    y: args.state.progress_bar[:main][:y],
    text: '',
    size_enum: 2,
    vertical_alignment_enum: 2,
    r: 255, g: 255, b: 255
  }

  args.state.sub_progress_label = {
    x: args.state.sub_progress_bar[:main][:x],
    y: args.state.sub_progress_bar[:main][:y],
    text: '',
    size_enum: 2,
    vertical_alignment_enum: 2,
    r: 255, g: 255, b: 255
  }

  args.state.fragment_block = {
    x: 0, y: 0,
    w: 20, h: 20,
    path: :pixel,
    r: 0, g: 0, b: 0
  }

  args.state.fragment_sprite = {
    x: 60, y: 160,
    w: 1180, h: 540,
    path: :fragment
  }

  $task = {}
  $sub_task = {}

  true
end

def create_process_fiber
  Fiber.new do
    task!(tasks: 13)

    v_all = task "Loading general vectors..." do
      parse_vec read_file "data/vec_all.txt"
    end

    v_ratio = task "Loading ratio vectors..." do
      parse_vec read_file "data/vec_ratio.txt"
    end

    answers = task "Loading possible answers..." do
      read_file("data/answers.txt").split("\n").map!(&:to_sym)
    end

    other_words = task "Loading other valid words..." do
      read_file("data/other_words.txt").split("\n").map!(&:to_sym)
    end

    words = answers + other_words

    invalid_results = task "Loading valid responses..." do
      parse_inv read_file "data/invalid_results.txt"
    end

    tweets = task "Loading tweets..." do
      parse_tweets read_file "data/tweets.txt"
    end

    task "Reticulating Splines..."
    wait 30

    task "Still Reticulating Splines..."
    wait 30

    task "Reticulating Splines... (No really, this is important)"
    wait 60

    vec_locs = [:Y, :M, :N].then do |letters|
      ([letters] * 5)
        .reduce(:product)
        .map! { _1.flatten.join.to_sym }
        .sort!
    end

    games = tweets[DAY].map{ |id, g| g }

    all_counts = counter(games.find_all { |g| g.length > 1 && g[-1] == :YYYYY }.flatten)

    # This isn't used
    # first_counts = counter(games.find_all {|g| g.length > 1 && g[-1] == :YYYYY}.map {|g| g[0]})
    penultimate_counts = counter(games.find_all { |g| g.length > 1 && g[-1] == :YYYYY }.map { |g| g[-2] })

    vec_all = vec_locs.map { |res| all_counts[res] || 0 }

    # These 2 here aren't used for anything?
    # vec_first = vec_locs.map {|res| first_counts[res] || 0}
    # vec_penultimate = vec_locs.map {|res| penultimate_counts[res] || 0}

    vec_ratio = vec_locs.map { |res| (penultimate_counts[res] || 0) / ((all_counts[res] || 0) + 1e-6)}

    task "Calculating probabilities..."

    dists = { all: {}, ratio: {}, invalid: {} }
    list_length = words.length

    sub_task!(tasks: list_length, state: :dist_calc)

    str = "Calculating for word: @@@@@"
    words.each_with_index do |word, i|
      GC.start if (i % 1000) == 0
      str[22..26] = word.to_s
      sub_task str
      dists[:all][word] = cosine(vec_all, v_all[word])
      dists[:ratio][word] = cosine(vec_ratio, v_ratio[word])
      dists[:invalid][word] = games.count { intersect? invalid_results[word], _1 }
    end

    sub_task_clear!

    task "Sorting results..."

    ranks = {}
    dists.each do |type, value|
      s = value.sort_by{ |k, v| -v }
      ranks[type] = {}
      s.length.times { |i| ranks[type][s[i][0]] = i }
    end

    task "Determining guess..."
    overall = {}
    words.each do |word|
      overall[word] = ranks.map { |k, v| v[word] }
    end

    overall_s = overall.sort_by { |k, v| v }
    my_guess = overall_s[0][0]
    answer = answers[DAY]
    answer_rank = overall_s.map { |a| a[0] }.index(answer)

    feedback = evaluate_guess(answer.to_s, my_guess.to_s).join

    if answer == my_guess
      feedback.concat(" !!!!!!")
    else
      feedback.concat(" :(:( the actual answer was #{answer}, which ranked #{answer_rank} on my guess list")
    end

    task "FINISHED..."

    "Guessed for day #{DAY}, my guess is #{my_guess}, #{feedback}"
  end
end

def task! task_hash: nil, **opts
  opts ||= {}
  opts[:task]  ||= 0
  opts[:tasks] ||= 1
  opts[:state] ||= :default

  task_hash ||= $task ||= {}
  task_hash.clear
  task_hash.merge! opts
end

def sub_task! opts = nil
  $sub_task ||= {}
  task! task_hash: $sub_task, **opts
end

def task_clear!
  $task.clear
end

def sub_task_clear!
  $sub_task.clear
end

def task info = nil, task_hash: $task, &block
  Fiber.yield task_hash[:info] = info

  ret = instance_eval &block if block
  task_hash[:task] += 1

  ret
end

def sub_task info = nil, &block
  task info, task_hash: $sub_task, &block
end

def wait ticks
  init = Kernel.tick_count
  Fiber.yield until init.elapsed? ticks
end

def read_file path
  $gtk.read_file(path).tr("\r", '')
end

def parse_vec str
  lines = str.split("\n")
  sub_task!(tasks: lines.size / 32, state: :parse_vec)

  ret = lines.map.with_index do |ln, i|
    sub_task "Vec#{i}" if i.zmod? 32

    a, b = ln.split(':')
    [a.to_sym, eval(b)]
  end.to_h

  sub_task_clear!

  ret
end

def parse_inv str
  lines = str.split("\n")
  sub_task!(tasks: lines.size / 32, state: :parse_inv)

  ret = lines.map.with_index do |ln, i|
    sub_task "Data#{i}" if i.zmod? 32

    a, b = ln.split(":");
    [a.to_sym, eval(b.tr('{}', '[]'))]
  end.to_h

  sub_task_clear!

  ret
end

def parse_tweets str
  lines = str.split("\n")
  sub_task!(tasks: lines.size / 128, state: :parse_tweets)

  ret = lines.each_with_object(Hash.new { |h, k| h[k] = {} }).with_index do |(ln, mem), i|
    sub_task "Tweet #{i}" if i.zmod? 128

    day, id, guesses = ln.split ';'
    mem[day.to_i][id] = eval(guesses).map!(&:to_sym)
  end

  sub_task_clear!

  ret
end

def cosine(v1, v2)
  dot_product = 0
  a = 0
  b = 0

  v1.size.times do |i|
    c, d = v1[i], v2[i]
    dot_product += c*d
    a += c*c
    b += d*d
  end

  dot_product / (Math.sqrt(a * b))
end

def counter list
  list.each_with_object(Hash.new 0) { |c, h| h[c] += 1 }
end

def evaluate_guess(answer, guess)
  matches = guess.chars.to_h { [_1, 0] }
  ans_letters = counter(answer.chars)
  res = guess.each_char.with_index.map do |c, i|
    if answer[i] == c
      matches[c] += 1
      'Y'
    end
  end

  guess.each_char.with_index do |c, i|
    next if res[i]
    if answer.include?(c) && matches[c] < (ans_letters[c] || 0)
      res[i] = 'M'
      matches[c] += 1
    else
      res[i] = 'N'
    end
  end

  res
end

def intersect? a, b
  hash = {}
  idx = 0
  len = b.size
  while idx < len
    hash[b[idx]] = true
    idx += 1
  end

  idx = 0
  len = a.size
  while idx < len
    return true if hash[a[idx]]
    idx += 1
  end

  false
end