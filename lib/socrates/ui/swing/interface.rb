#!/usr/bin/env ruby
# encoding: UTF-8

abort "Use JRuby to run this!" unless RUBY_PLATFORM == "java"
#unless ENV["JRUBY_OPTS"].include? "--1.9"
#  abort "Please include '--1.9' in JRUBY_OPTS" 
#end

require 'java'

swing_classes = %w(JFrame JButton JList JSplitPane
             JTabbedPane JTextPane JScrollPane JEditorPane
             DefaultListModel ListSelectionModel BoxLayout
             JScrollPane JTree tree.TreeModel
             text.html.HTMLEditorKit tree.DefaultMutableTreeNode tree.TreeNode)
swing_classes.each do |c|
  java_import "javax.swing.#{c}"
end

include Java

import javax.swing.JFrame
import javax.swing.JLabel
import javax.swing.JTextField
import javax.swing.JTextArea
import javax.swing.JButton
import javax.swing.JPanel

require 'profligacy/swing'
require 'profligacy/lel'
include Profligacy

def add_node(parent, item)
  node = DefaultMutableTreeNode.new(item)
  parent.insert(node, 0)
  item.children.each {|child| add_node(node, child) }
end

layout = <<EOF
  [ (300,400)*panel1  | panel2 ]
EOF

layout3 = <<EOF
  [ ^label           | many ]
  [ (100,340)*panel3 | ^go   ]
EOF

c = c2 = c3 = nil
topic_root = Socrates::TopicStore::Root
tree_root = nil

ui = Swing::LEL.new(JFrame, layout) do |c, i|
  c.panel1 = Swing::LEL.new(JPanel, "[tree]") do |c2, i2|
    tree_root = DefaultMutableTreeNode.new(root)
    c2.tree = JTree.new(tree_root)
  end.build :auto_create_container_gaps => false
  c.panel2 = Swing::LEL.new(JPanel, layout3) do |c3, i3|
    c3.label = JLabel.new "How many questions?"
    c3.many = JTextField.new 4
    c3.go   = JButton.new "Go!"
    c3.panel3 = Swing::LEL.new(JPanel, "[_]") do |c4, i4|
    end.build :auto_create_container_gaps => false
  end.build :auto_create_container_gaps => false
end

ui.build(:args => "Simple LEL Example")
ui.container.default_close_operation = JFrame::EXIT_ON_CLOSE
c3.go.add_action_listener { puts c3.many.text; puts c2.tree.selection_path }

root.children.each {|ch| add_node(tree_root, ch) }
c2.tree.expand_row(0)

