from typing import Type
import unittest
from unittest.mock import patch
from src.python import analysis as an

class TestAnalysis(unittest.TestCase):
  
  @classmethod
  def setupClass(cls):
    pass
  
  def setup(self):
    pass
  
  def test_hello(self):
    self.assertEqual(an.hello(), 'hello')
    
  def test_get_args(self):
    args = an.get_args(['--path', './home', '--outdir', './outs'])
    self.assertEqual(args, ('./home', './outs'))
    
    missing_outdir = an.get_args(['--path', './home'])
    self.assertEqual(missing_outdir, ('./home', None))
    
    missing_path = an.get_args(['--outdir', './outs'])
    self.assertEqual(missing_path, (None, './outs'))
    
    missing_args = an.get_args([])
    self.assertEqual(missing_args, (None, None))
    
  
  def test_setup_anndata(self):
    self.assertRaises(TypeError, an.setup_anndata)
    # with self.assertRaises(TypeError) as context:
    #   an.setup_anndata()
    # self.assertTrue('missing 1 required positional argument' in str(context.exception))
    
  def test_plot_top_genes(self):
    self.assertRaises(TypeError, an.plot_top_genes)
  
  def test_apply_qc(self):
    self.assertRaises(TypeError, an.apply_qc)
  
  def test_calc_variable_genes(self):
    self.assertRaises(TypeError, an.calc_variable_genes)

  def test_run_pca(self):
    self.assertRaises(TypeError, an.run_pca)
  
  def test_run_neighbors(self):
    self.assertRaises(TypeError, an.run_neighbors)
  
  def test_run_leiden_cluster(self):
    self.assertRaises(TypeError, an.run_leiden_cluster)
  
  def test_rank_genes(self):
    self.assertRaises(TypeError, an.rank_genes)
  
  def test_plot_marker_clusters(self):
    self.assertRaises(TypeError, an.plot_marker_clusters)

    
if __name__ == '__main__':
  unittest.main()